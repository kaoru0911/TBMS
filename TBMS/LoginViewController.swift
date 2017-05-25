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
    
    var serverCommunicate: ServerConnector = ServerConnector()
    
    var sharedData = DataManager.shareDataManager
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    
    @IBAction func loginBtn(_ sender: Any) {
        
    if (inputAccountName.text! == (sharedData.memberData?.account)! && inputPassword.text == (sharedData.memberData?.password)!){
    serverCommunicate.userLogin()
        print("登入成功")
                }
    
        
    }

    }

