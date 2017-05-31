//
//  ServerConnector.swift
//  TravelByMyself
//
//  Created by popcool on 2017/5/10.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit
import Alamofire
//import ObjectMapper

class ServerConnector: NSObject {
    
    // URL
    let baseURLStr: String = "http://localhost/TravelByMyself/"
    
    //let memberURLstr: String = "member.php"
    let memberURLstr: String = "login.php"
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
    
    
    
    func userLogin() {
        
        
        guard ((sharedData.memberData?.account) != nil) ||
            ((sharedData.memberData?.password) != nil) else {
                
            print("account or password is nil")
                
            sharedData.isLogin = false
                
            return
        }
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     PASSWORD_KEY: sharedData.memberData!.password! as Any,
                                     REQUEST_KEY: LOGIN_REQ]
        
        Alamofire.request(baseURLStr + memberURLstr, method: .post, parameters: parameters).responseString { response in
            
            //debugPrint(response)
            //print("Is login post success: \(response)")
            //print("Is login post success: \(response.result.isSuccess)")
            //print("Response: \(String(describing: response.result.value))")
           
            
            if response.result.isSuccess == true {
                self.sharedData.isLogin = true
            } else {
                self.sharedData.isLogin = false
            }
            
            // 通知中心
            let notificationName = Notification.Name("loginResponse")
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["PASS":response.result.isSuccess])
        }
    }
    
    func theMethodWhereYouGo(notification: NSNotification) {
        
        /* 從叫notifiName的本地通知傳送 notification參數過來 */
    }
    
    func createAccount() {
        
        guard ((sharedData.memberData?.account) != nil) ||
            ((sharedData.memberData?.password) != nil) ||
            ((sharedData.memberData?.email) != nil)else {
                
                print("account or password or email is nil")
                
                return
        }
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     PASSWORD_KEY: sharedData.memberData!.password! as Any,
                                     EMAIL_KEY: sharedData.memberData!.email! as Any,
                                     REQUEST_KEY: CREATE_REQ]
        
        
        Alamofire.request(baseURLStr + memberURLstr, method: .post, parameters: parameters).responseString { response in
            
            debugPrint(response)
            print("Is create new account post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            //if response.result.isSuccess == true {
            //    self.memberLogin(sharedData:sharedData)
            //}
        }
    }
    
    func userInfoUpdate() {
        
        guard ((sharedData.memberData?.account) != nil) ||
            ((sharedData.memberData?.password) != nil) ||
            ((sharedData.memberData?.email) != nil)else {
                
                print("account or password or email is nil")
                
                return
        }
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     PASSWORD_KEY: sharedData.memberData!.password! as Any,
                                     EMAIL_KEY: sharedData.memberData!.email! as Any,
                                     REQUEST_KEY: UPDATEINFO_REQ]
        
        
        Alamofire.request(baseURLStr + memberURLstr, method: .post, parameters: parameters).responseString { response in
            
            debugPrint(response)
            print("Is update user info post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            
        }
    }
    
    func getPocketTripFromServer() {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     REQUEST_KEY: DOWNLOAD_POCKETTRIP_REQ]
        
        
        Alamofire.request(baseURLStr + dataDownloadURLstr, method: .post, parameters: parameters).responseString { response in
            
            debugPrint(response)
            print("Is download pocketTrip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
        }
        
    }
    
    func getSharedTripFromServer() {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     REQUEST_KEY: DOWNLOAD_SHAREDTRIP_REQ]
        
        
        Alamofire.request(baseURLStr + dataDownloadURLstr, method: .post, parameters: parameters).responseString { response in
            
            debugPrint(response)
            print("Is download sharedTrip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
        }
        
    }
    
    func getPocketSpotFromServer() {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     REQUEST_KEY: DOWNLOAD_POCKETSPOT_REQ]
        
        
        Alamofire.request(baseURLStr + dataDownloadURLstr, method: .post, parameters: parameters).responseString { response in
            
            debugPrint(response)
            print("Is download pocket spot post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
        }
    }
    
    func uploadPocketSpotToServer(spotName:String) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     SPOTNAME_KEY: spotName,
                                     REQUEST_KEY: UPLOAD_POCKETSPOT_REQ]
        
        
        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseString { response in
            
            debugPrint(response)
            print("Is upload pocket spot post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
        }
    }
    
    func uploadSharedTripToServer(tripData:tripData) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     TRIPNAME_KEY: tripData.tripName as Any,
                                     TRIPDAYS_KEY: tripData.days as Any,
                                     TRIPCOUNTRY_KEY: tripData.country as Any,
                                     REQUEST_KEY: UPLOAD_SHAREDTRIP_REQ]
        
        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseString { response in
            
            debugPrint(response)
            print("Is upload shared trip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
        }
    }
    
    func uploadPocketTripToServer(tripData:tripData) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     TRIPNAME_KEY: tripData.tripName as Any,
                                     TRIPDAYS_KEY: tripData.days as Any,
                                     TRIPCOUNTRY_KEY: tripData.country as Any,
                                     REQUEST_KEY: UPLOAD_POCKETTRIP_REQ]
        
        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseString { response in
            
            debugPrint(response)
            print("Is upload shared trip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
        }
    }
    
//    private func uploadTripSpotToServer(tripData:tripData) {
//        
//        uploadIndex -= 1
//        
//        guard uploadIndex >= 0 else {
//            
//            uploadIndex = 0
//            return
//        }
//        
//        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
//        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
////                                     TRIPNAME_KEY: tripData.spots[uploadIndex].belongTripName as Any,
//                                     SPOTNAME_KEY: tripData.spots[uploadIndex].spotName as Any,
//                                     NDAY_KEY: tripData.spots[uploadIndex].nDays as Any,
//                                     NTH_KEY: tripData.spots[uploadIndex].nTh as Any,
//                                     TRAFFIC_KEY: tripData.spots[uploadIndex].trafficToNextSpot as Any,
//                                     REQUEST_KEY: UPLOAD_TRIPSPOT_REQ]
//        
//        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseString { response in
//            
//            debugPrint(response)
//            print("Is upload trip spot post success: \(response.result.isSuccess)")
//            print("Total count in spot array: \(String(tripData.spots.count))")
//            print("Upload index in spot array: \(String(self.uploadIndex))")
//            print("Response: \(String(describing: response.result.value))")
//            
//            if(self.uploadIndex > 0){
//                self.uploadTripSpotToServer(tripData: tripData)
//            }
//        }
//    }
    
    
    func getMemberInfo(){
        
        
        Alamofire.request(baseURLStr + memberURLstr).responseString { response in
            
            debugPrint(response)
            
            print("IsSuccess: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
        }
    }

}
