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

    @IBAction func emailRegisterBtn(_ sender: Any) {
        
        if ((inputAccount.text?.characters.count)! < 6) {
            let alert = UIAlertController(title: "會員註冊", message:"會員名稱至少需6個字母", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
        }
        
        if ((inputPassword.text?.characters.count)! < 6) {
            let alert = UIAlertController(title: "會員註冊", message:"會員密碼至少需6個字母", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
        }
        
        guard inputAccount.text != nil && inputAccount.text != "" && inputPassword.text != nil && inputPassword.text != "" else {
            return
        }
        sharedData.memberData?.account = inputAccount.text
        
        sharedData.memberData?.password = inputPassword.text
                
        serverCommunicate.createAccount()
        
        let alert = UIAlertController(title: "會員註冊", message:"註冊成功", preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true,completion: nil)

        
//                return
        
    }

}
