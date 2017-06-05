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
    
    @IBOutlet weak var FBLoginBtn: FBSDKLoginButton!
   
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var gmailLoginBtn: GIDSignInButton!
    @IBOutlet weak var newMemberRegisterBtn: UIButton!
    
    var serverCommunicate: ServerConnector = ServerConnector()
    var sharedData = DataManager.shareDataManager
    var loginResponse = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginBtn.layer.cornerRadius = 5.0
        newMemberRegisterBtn.layer.cornerRadius = 5.0
        
        FBLoginBtn.readPermissions = ["public_profile", "email", "user_friends"]
        FBLoginBtn.delegate = self
        
        //  FB第一次登入後可取得使用者token，後續即可直接登入
        if (FBSDKAccessToken.current()) != nil{
            //            fetchProfile()
        }

        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "loginNotifier"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        print("成功登入")
        
        fetchProfile()
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let nextPage = segue.destination as! MemberViewController
//    }
    
    @IBAction func loginBtn(_ sender: Any) {
        
        if (inputAccountName.text?.isEmpty)! || (inputPassword.text?.isEmpty)! {
            showAlertMessage(title: "Fail", message: "請輸入帳號與密碼")
            return
        }
            
        sharedData.memberData?.account = inputAccountName.text
        
        sharedData.memberData?.password = inputPassword.text
    
        serverCommunicate.userLogin()

    }
    
//    func getUpdateNoti(noti:Notification) {
//        loginResponse = noti.userInfo!["PASS"] as! Bool
//    }
    
    func NotificationDidGet() {
        
        if self.sharedData.isLogin == true {
            
            showAlertMessage(title: "Success", message: "登入成功")
            
            performSegue(withIdentifier: "goMemberVC" , sender: nil)
            
            
////            // Dismiss the Old
////            if let presented = self.presentedViewController {
////                presented.removeFromParentViewController()
////            }
//            
//            if presentedViewController != nil {
//                removeFromParentViewController()
//            }
//            
//            // Present the New
//            let main = UIStoryboard(name: "Main", bundle: nil)
//            let memberVC = main.instantiateViewController(withIdentifier: "MemberViewController") as! MemberViewController
//            self.present(memberVC, animated: true, completion: nil)
            
            
        } else if self.sharedData.isLogin == false {
            
            showAlertMessage(title: "Fail", message: "登入失敗，請確認帳號或密碼是否正確")
        }
    }
    
    func showAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert,animated: true,completion: nil)
    }
    @IBAction func gmailLogoutBtn(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        print("gmail log out")

    }
}




