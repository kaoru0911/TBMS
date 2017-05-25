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
        
        guard inputAccount.text != nil && inputAccount.text != "" && inputPassword.text != nil && inputPassword.text != "" else {
            return
        }
        sharedData.memberData?.account = inputAccount.text
        
        sharedData.memberData?.password = inputPassword.text
                
        serverCommunicate.createAccount()
                
//                return
        
    }

}
