//
//  LoginViewController.swift
//  TBMS
//
//  Created by Ryder Tsai on 2017/5/24.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var inputAccountName: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var newMemberRegisterBtn: UIButton!
    
    var serverCommunicate: ServerConnector = ServerConnector()
    var sharedData = DataManager.shareDataManager
    var loginResponse = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginBtn.layer.cornerRadius = 5.0
        newMemberRegisterBtn.layer.cornerRadius = 5.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "loginNotifier"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        customActivityIndicatory(self.view, startAnimate: true)
    }
    
//    func getUpdateNoti(noti:Notification) {
//        loginResponse = noti.userInfo!["PASS"] as! Bool
//    }
    
    func NotificationDidGet() {
        
        customActivityIndicatory(self.view, startAnimate: false)
        
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
    
    func customActivityIndicatory(_ viewContainer: UIView, startAnimate:Bool? = true) {
        
        // 做一個透明的view來裝
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
        // background的alpha跟view的alpha不同
        mainContainer.alpha = 0.5
        //================================
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        // 旋轉圈圈放在這個view上
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = viewContainer.center
        //        viewBackgroundLoading.backgroundColor = UIColor(red:0x7F, green:0x7F, blue:0x7F, alpha: 1)
        viewBackgroundLoading.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 1)
        //================================
        //        viewBackgroundLoading.alpha = 0.5
        //================================
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        // 創造旋轉圈圈
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }
        //        return activityIndicatorView
    }

}




