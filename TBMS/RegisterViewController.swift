//
//  LoginViewController.swift
//  TravelByMySelf
//
//  Created by Ryder Tsai on 2017/4/19.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn


class RegisterViewController: UIViewController, GIDSignInUIDelegate {
    
    //@IBOutlet weak var FBLoginBtn: FBSDKLoginButton!
    @IBOutlet weak var gmailLoginBtn: GIDSignInButton!
    @IBOutlet weak var emailRegisterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
    
        
        gmailLoginBtn.layer.cornerRadius = 5.0
        emailRegisterBtn.layer.cornerRadius = 5.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    
    
    @IBAction func gmailLogoutBtn(_ sender: Any) {
            }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
