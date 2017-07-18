//
//  LoginViewController.swift
//  TBMS
//
//  Created by Ryder Tsai on 2017/5/24.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var inputAccountName: UITextField!
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var pswLabel: UILabel!
    @IBOutlet weak var FBLoginBtn: FBSDKLoginButton!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var gmailLoginBtn: GIDSignInButton!
    @IBOutlet weak var newMemberRegisterBtn: UIButton!
    
    var serverCommunicate: ServerConnector = ServerConnector()
    var sharedData = DataManager.shareDataManager
    let generalModels = GeneralToolModels()
    var loginResponse = Bool()
    var fbAccess: String?
    
    let userDefault = UserDefaults.standard
    
    let getPocketSpotAfterLoginNotifier = Notification.Name(NotificationName.getPocketSpotAfterLoginNotifier.rawValue)
    let loginNotifier = Notification.Name(NotificationName.loginNotifier.rawValue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loginBtn.layer.cornerRadius = 5.0
        newMemberRegisterBtn.layer.cornerRadius = 5.0
        
        FBLoginBtn.readPermissions = ["public_profile", "email", "user_friends"]
        FBLoginBtn.delegate = self
        
        gmailLoginBtn.isHidden = true
        
        //  FB第一次登入後可取得使用者token，後續即可直接登入
        if (FBSDKAccessToken.current()) != nil{
            //            fetchProfile()
        }
        
        if userDefault.string(forKey: "FBSDKAccessToken") != nil {
            loginBtn.isHidden = true
            inputPassword.isHidden = true
            inputAccountName.isHidden = true
            accountLabel.isHidden = true
            pswLabel.isHidden = true
            newMemberRegisterBtn.isHidden = true
        }
        
        // dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if sharedData.isLogin == true {
            performSegue(withIdentifier: "goMemberVC", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fbLoginNotificationDidGet),
                                               name: NSNotification.Name(rawValue: "fbLoginNotifier"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logoutNotificationDidGet),
                                               name: NSNotification.Name(rawValue: "logoutNotifier"),
                                               object: nil)
        
    }
    
    
    // For pressing return on the keyboard to dismiss keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    // FB登入按鈕
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        guard let loginResult =  FBSDKAccessToken.current().userID  else {
            
            print("登入失敗", error)
            return
        }
        //
        print("成功登入")
        
        fbAccess = loginResult
        
        sharedData.memberData?.account = fbAccess
        
        sharedData.memberData?.password = fbAccess
        
        userDefault.set(fbAccess, forKey: "FBSDKAccessToken")
        
        serverCommunicate.useFBLogin()
        
        fetchProfile()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        serverCommunicate.userLogout()
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func fetchProfile(){
        print("fetch profile")
        
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: {
            connection, result, error -> Void in
            
            if error != nil {
                print("longinerror =\(String(describing: error))")
            } else {
                
                if let resultNew = result as? [String:Any]{
                    
                    let email = resultNew["email"]  as! String
                    print(email)
                    
                    let firstName = resultNew["first_name"] as! String
                    print(firstName)
                    
                    let lastName = resultNew["last_name"] as! String
                    print(lastName)
                    
                    if let picture = resultNew["picture"] as? NSDictionary,
                        let data = picture["data"] as? NSDictionary,
                        let url = data["url"] as? String {
                        print(url) //臉書大頭貼的url, 再放入imageView內秀出來
                    }
                }
            }
        })
    }
    
    // 會員登入
    @IBAction func loginBtn(_ sender: Any) {
        
        if (inputAccountName.text?.isEmpty)! || (inputPassword.text?.isEmpty)! {
            let alert = generalModels.prepareCommentAlertVC(title: "Fail", message: "請輸入帳號與密碼")
            present(alert, animated: true, completion: nil)
            return
        }
        
        sharedData.memberData?.account = inputAccountName.text
        
        sharedData.memberData?.password = inputPassword.text
        
        serverCommunicate.userLogin()
        
        generalModels.customActivityIndicatory(self.view, startAnimate: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoginNotificationDidGet), name: self.loginNotifier, object: nil)
        
    }
    
    //    func getUpdateNoti(noti:Notification) {
    //        loginResponse = noti.userInfo!["PASS"] as! Bool
    //    }
    
    
    func userLoginNotificationDidGet() {
        
        NotificationCenter.default.removeObserver(self, name: self.loginNotifier, object: nil)
        
        guard self.sharedData.isLogin == true else {
            let alert = generalModels.prepareCommentAlertVC(title: "Fail", message: "登入失敗，請確認帳號或密碼是否正確")
            present(alert, animated: true, completion: nil)
            return
        }
        
        if sharedData.selectedProcess == .none {
            
            generalModels.customActivityIndicatory(self.view, startAnimate: false)
            let alert = generalModels.prepareCommentAlertVC(title: "Success", message: "登入成功")
            present(alert, animated: true, completion: nil)
            
            // =============================================
            // 創造一個新個TabBarController與NavigationController，再放回appDelegate內取代原本的root
            // =============================================
            
            // TabBar
            let rootTabBarController = UITabBarController()
            
            // 注意！創造viewController的方式跟創造view的方式不同
            //            let rightTab = MemberViewController()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rightTab = storyboard.instantiateViewController(withIdentifier: "MemberViewController") as! MemberViewController
            rightTab.title = "會員專區"
            
            let rightTabBarItem = UITabBarItem(title: "會員專區", image: UIImage(named: "circle-user-7.png"), tag: 0)
            rightTab.tabBarItem = rightTabBarItem
            
            // Navigation
            let rightNavigation = UINavigationController(rootViewController: rightTab)
            
            //            let leftTab = MenuTableViewController()
            let leftTab = storyboard.instantiateViewController(withIdentifier: "MenuTableViewController") as! MenuTableViewController
            leftTab.title = "TravelByMyself"
            
            let leftTabBarItem = UITabBarItem(title: "旅遊選單", image: UIImage(named: "airplane-symbol-7.png"), tag: 0)
            leftTab.tabBarItem = leftTabBarItem
            
            // Navigation
            let leftNavigation = UINavigationController(rootViewController: leftTab)
            
            rootTabBarController.viewControllers = [leftNavigation, rightNavigation]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = rootTabBarController
            
            
        } else {
            
            print("NOTE: Entering doSomeWorkAfterLoginNotifierDidGet")
            doSomeWorkAfterLoginNotifierDidGet()
        }
    }
    
    func doSomeWorkAfterLoginNotifierDidGet() {
        
        guard let previousVC = generalModels.getPreviousVCinNavigationVC(selfVC: self, distanceIndex: 1) else {
            
            print("ERROR: previousVC of LoginVC doesn't exist.")
            return
        }
        
        if previousVC is AddViewPointViewController {
            
            guard sharedData.pocketSpot?.count == 0 else {
                print("WARNING: pocketSpot exist before login.")
                return
            }
            
            serverCommunicate.getPocketSpotFromServer(doSecondTypeNotifierPost: true, targetVC: self)
            NotificationCenter.default.addObserver(self, selector: #selector(spotDownLoadNotifierDidGet), name: self.getPocketSpotAfterLoginNotifier, object: nil)
            
        } else if previousVC is UploadTravelScheduleViewController {
            
            self.navigationController?.popToViewController(previousVC, animated: true)
        }

    }
    
    func spotDownLoadNotifierDidGet() {
        
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
        
        guard let previosVC = generalModels.getPreviousVCinNavigationVC(selfVC: self, distanceIndex: 1) else {
            print("ERROR: spotDownLoadNotifierDidGet but previosVC doesn't exist.")
            return
        }
    
        self.navigationController?.popToViewController(previosVC, animated: true)
    }
    
    
    func fbLoginNotificationDidGet() {
        
        loginBtn.isHidden = true
        inputPassword.isHidden = true
        inputAccountName.isHidden = true
        accountLabel.isHidden = true
        pswLabel.isHidden = true
        newMemberRegisterBtn.isHidden = true
        
        guard sharedData.selectedProcess != .none else { return }
        
        print("NOTE: Entering doSomeWorkAfterLoginNotifierDidGet")
        doSomeWorkAfterLoginNotifierDidGet()
    }
    
    func logoutNotificationDidGet() {
        loginBtn.isHidden = false
        inputPassword.isHidden = false
        inputAccountName.isHidden = false
        accountLabel.isHidden = false
        pswLabel.isHidden = false
        newMemberRegisterBtn.isHidden = false
    }
}




