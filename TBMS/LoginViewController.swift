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

    }
    
//    func getUpdateNoti(noti:Notification) {
//        loginResponse = noti.userInfo!["PASS"] as! Bool
//    }
    
    func NotificationDidGet() {
        
        if self.sharedData.isLogin == true {
            
            showAlertMessage(title: "Success", message: "登入成功")
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
}




