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


class RegisterViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var FBLoginBtn: FBSDKLoginButton!

    @IBOutlet weak var gmailLoginBtn: GIDSignInButton!
    @IBOutlet weak var emailRegisterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBLoginBtn.readPermissions = ["public_profile", "email", "user_friends"]
        FBLoginBtn.delegate = self
        
        //        第一次登入後可取得使用者token，後續即可直接登入
        if (FBSDKAccessToken.current()) != nil{
            //            fetchProfile()
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().delegate = self
        
     
        gmailLoginBtn.layer.cornerRadius = 5.0
        emailRegisterBtn.layer.cornerRadius = 5.0
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
                print("longinerror =\(error)")
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
    
    
    @IBAction func gmailLogoutBtn(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
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
