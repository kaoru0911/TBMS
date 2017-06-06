//
//  EmailRegisterViewController.swift
//  TBMS
//
//  Created by Ryder Tsai on 2017/5/24.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit

class EmailRegisterViewController: UIViewController {
    @IBOutlet weak var inputPassword: UITextField!

    @IBOutlet weak var inputAccount: UITextField!
    
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    var serverCommunicate: ServerConnector = ServerConnector()
    
    var sharedData = DataManager.shareDataManager
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerBtn.layer.cornerRadius = 5.0
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

    func isValidPassword(candidate: String) -> Bool {
        
        //驗證用户名或密碼的正則表達式：”^[a-zA-Z]\w{5,15}$”
        //驗證Email地址：(“^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\.\\w+([-.]\\w+)*$”)；
        let passwordRegex = "(?=.[a-z])(?=.[A-Z])(?=.*\\d).{6,15}"
        
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: candidate)
    }
    
    @IBAction func emailRegisterBtn(_ sender: Any) {
        
        if isValidPassword(candidate: inputPassword.text!) {
            print("password is good")
        } else {
            print("password is wrong")
        }
        
        
        if ((inputAccount.text?.characters.count)! <= 6) {
            let alert = UIAlertController(title: "會員註冊", message:"會員名稱至少需6個字元", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
        }
        
        if ((inputPassword.text?.characters.count)! < 6) {
            let alert = UIAlertController(title: "會員註冊", message:"會員密碼至少需6個字元", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
        }
        
        guard inputAccount.text != nil && inputAccount.text != "" && inputPassword.text != nil && inputPassword.text != "" else {
            return
        }
        sharedData.memberData?.account = inputAccount.text
        
        sharedData.memberData?.password = inputPassword.text
        
        sharedData.memberData?.email = inputEmail.text
                
        serverCommunicate.createAccount()
        
        let alert = UIAlertController(title: "會員註冊", message:"註冊成功", preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true,completion: nil)

        
//                return
        
    }

}
