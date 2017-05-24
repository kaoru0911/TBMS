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
    
    // URL
    let baseURLStr: String = "http://localhost/TravelByMyself/"
    let memberURLstr: String = "member.php"
    let dataDownloadURLstr: String = "dataDownload.php"
    let dataUploadURLstr: String = "dataUpload.php"
    
    let REQUEST_KEY: String = "request"
    
    // Key-member
    let USER_NAME_KEY: String = "username"
    let PASSWORD_KEY: String = "password"
    let EMAIL_KEY: String = "email"
    
    // Key-trip & spot
    let SPOTNAME_KEY: String = "spotName"
    let TRIPNAME_KEY: String = "tripName"
    let TRIPDAYS_KEY: String = "tripDays"
    let TRIPCOUNTRY_KEY: String = "tripCountry"
    let NDAY_KEY: String = "nDay"
    let NTH_KEY: String = "nTh"
    let TRAFFIC_KEY: String = "traffic"
    
    
    // request
    let LOGIN_REQ: String = "login"
    let CREATE_REQ: String = "create"
    let GET_POCKETTRIP_REQ: String = "getPocketTrip"
    let UPDATEINFO_REQ: String = "updateUserInfo"
    let DOWNLOAD_POCKETTRIP_REQ: String = "downloadPocketTrip"
    let DOWNLOAD_POCKETSPOT_REQ: String = "downloadPocketSpot"
    let DOWNLOAD_SHAREDTRIP_REQ: String = "downloadSharedTrip"
    
    let UPLOAD_POCKETSPOT_REQ: String = "uploadPocketSpot"
    let UPLOAD_SHAREDTRIP_REQ: String = "uploadSharedTrip"
    let UPLOAD_POCKETTRIP_REQ: String = "uploadPocketTrip"
    let UPLOAD_TRIPSPOT_REQ: String = "uploadTripSpot"
    
    
    var sharedData = DataManager.shareDataManager
    var uploadIndex:Int = 0
    
    @IBAction func loginBtn(_ sender: Any) {
        
        guard ((sharedData.memberData?.account) != nil) ||
            ((sharedData.memberData?.password) != nil) else {
                
                print("account or password is nil")
                
                sharedData.isLogin = false
                
                return
                
    if (inputAccountName.text! == (sharedData.memberData?.account)! && inputPassword.text == (sharedData.memberData?.password)!){
                    
                }

    }

    }
}
