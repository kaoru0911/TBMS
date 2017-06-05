//
//  ServerConnector.swift
//  TravelByMyself
//
//  Created by popcool on 2017/5/10.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ServerConnector: NSObject {
    
    // URL
    let baseURLStr: String = "http://localhost/TravelByMyself/"
    let memberURLstr: String = "member.php"
    let dataDownloadURLstr: String = "dataDownload.php"
    let dataUploadURLstr: String = "dataUpload.php"
    let coverImgUploadURLstr: String = "coverImgUpload.php"
    
    let REQUEST_KEY: String = "request"
    
    // Key-member
    let USER_NAME_KEY: String = "username"
    let PASSWORD_KEY: String = "password"
    let EMAIL_KEY: String = "email"
    
    // Key-trip & spot
    let SPOTNAME_KEY: String = "spotName"
    let SPOTCOUNTRY_KEY: String = "spotCountry"
    let TRIPNAME_KEY: String = "tripName"
    let TRIPDAYS_KEY: String = "tripDays"
    let TRIPCOUNTRY_KEY: String = "tripCountry"
    let NDAY_KEY: String = "nDay"
    let NTH_KEY: String = "nth"
    let TRAFFICTITLE_KEY: String = "trafficTitle"
    let TRAFFIC_KEY: String = "traffic"
    let COVERIMG_KEY: String = "coverImg"
    let PLACEID_KEY: String = "placeID"
    
    // tripTye
    let SHAREDTRIP: String = "sharedTrip"
    let POCKETTRIP: String = "pocketTrip"
    
    // request
    let LOGIN_REQ: String = "login"
    let CREATE_REQ: String = "create"
    let GET_POCKETTRIP_REQ: String = "getPocketTrip"
    let UPDATEINFO_REQ: String = "updateUserInfo"
    let DOWNLOAD_POCKETTRIP_REQ: String = "downloadPocketTrip"
    let DOWNLOAD_POCKETSPOT_REQ: String = "downloadPocketSpot"
    let DOWNLOAD_SHAREDTRIP_REQ: String = "downloadSharedTrip"
    let DOWNLOAD_SHAREDTRIPSPOT_REQ: String = "downloadSharedTripSpot"
    let DOWNLOAD_POCKETTRIPSPOT_REQ: String = "downloadPocketTripSpot"
    
    let UPLOAD_POCKETSPOT_REQ: String = "uploadPocketSpot"
    let UPLOAD_SHAREDTRIP_REQ: String = "uploadSharedTrip"
    let UPLOAD_POCKETTRIP_REQ: String = "uploadPocketTrip"
    let UPLOAD_POCKETTRIPSPOT_REQ: String = "uploadPocketTripSpot"
    let UPLOAD_SHAREDTRIPSPOT_REQ: String = "uploadSharedTripSpot"
    let UPLOAD_SHAREDTRIPCOVER_REQ: String = "uploadSharedTripCover"
    let UPLOAD_POCKETTRIPCOVER_REQ: String = "uploadPocketTripCover"
    
    let DELETE_POCKETSPOT_REQ: String = "deletePocketSpot"
    let DELETE_POCKETTRIP_REQ: String = "deletePocketTrip"
    
    
    
    var sharedData = DataManager.shareDataManager
//    var uploadIndex: Int = 0
    var downloadImgIndex: Int = 0
    var threadKey = NSLock.init()
    
    let loginNotifier = Notification.Name("loginNotifier")
    let getPocketTripNotifier = Notification.Name("getPocketTripNotifier")
    let getSharedTripNotifier = Notification.Name("getSharedTripNotifier")
    let getPocketSpotNotifier = Notification.Name("getPocketSpotNotifier")
    let getTripSpotNotifier = Notification.Name("getTripSpotNotifier")
    let downloadCoverImgNotifier = Notification.Name("downloadCoverImgNotifier")
    
    
    /**
     user login to server, this function would callsingleton sharedData to use account and password
     */
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
        
        Alamofire.request(baseURLStr + memberURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is login post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? Dictionary<String,Any> else {
                        return
                    }
                
                    let result = getFeedback["result"] as! Bool
                
                    let error = getFeedback["errorCode"] as! String
                
                    self.sharedData.isLogin = result
                
                    print("Result: \(result), Error code:", error)
                
                case .failure(_):
                    self.sharedData.isLogin = false
                    print("Server feedback fail")
            }
            
            NotificationCenter.default.post(name: self.loginNotifier, object: nil)
        }
    }
    
    /**
     user create a new account, if success, user will login.
     */
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
        
        
        Alamofire.request(baseURLStr + memberURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is create new account post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? Dictionary<String,Any> else {
                        return
                    }
                    
                    let result = getFeedback["result"] as! Bool
                    
                    let error = getFeedback["errorCode"] as! String
                    
                    print("Result: \(result), Error code:", error)
                
                    if result {
                        self.userLogin()
                    }
                
                case .failure(_):
                    print("Server feedback fail")
            }
            
        }
    }
    
    /**
     When user file like email and password has been changed, use this function to update to server
     */
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
        
        
        Alamofire.request(baseURLStr + memberURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is update user info post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? Dictionary<String,Any> else {
                        return
                    }
                    
                    let result = getFeedback["result"] as! Bool
                    
                    let error = getFeedback["errorCode"] as! String
                    
                    print("Result: \(result), Error code:", error)
                    
                case .failure(_):
                    print("Server feedback fail")
            }
        }
    }
    
    /**
     Download user pocket trip from server, including cover image, but not include spot
     */
    func getPocketTripFromServer() {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     REQUEST_KEY: DOWNLOAD_POCKETTRIP_REQ]
        
        
        Alamofire.request(baseURLStr + dataDownloadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is download pocketTrip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? [Dictionary<String,Any>] else {
                        NotificationCenter.default.post(name: self.getPocketTripNotifier, object: nil)
                        return
                    }
                    
//                    self.downloadImgIndex = 0
                    
                    let ImgPathURL = self.baseURLStr + "pocketTripCoverImg/"
                    
                    var downloadImgName = [String]()
                    
                    for i in 0...getFeedback.count-1 {
                        
                        let pocketTrip:tripData = tripData()
                        
                        pocketTrip.tripName = getFeedback[i]["tripName"] as? String
                        
                        pocketTrip.days = getFeedback[i]["tripDays"] as? Int
                        
                        pocketTrip.country = getFeedback[i]["tripCountry"] as? String
                        
                        pocketTrip.ownerUser = getFeedback[i]["ownerUser"] as? String
                        
                        guard let coverImgName = getFeedback[i]["coverImg"] as? String else {
                            
                            downloadImgName.append("noImg")
                            continue
                        }
                        
                        downloadImgName.append(coverImgName)

                        
                        self.sharedData.pocketTrips?.append(pocketTrip)
                    }
                
                    self.downloadCoverImg(filePath: ImgPathURL, type: self.POCKETTRIP, imgName: downloadImgName)
                
                case .failure(_):
                    print("Server feedback fail")
            }
            
            NotificationCenter.default.post(name: self.getPocketTripNotifier, object: nil)
        }
    }
    
    /**
     Download all shared trip from server, including cover image, but not include spot
     */
    func getSharedTripFromServer() {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     REQUEST_KEY: DOWNLOAD_SHAREDTRIP_REQ]
        
        
        Alamofire.request(baseURLStr + dataDownloadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is download sharedTrip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? [Dictionary<String,Any>] else {
                        NotificationCenter.default.post(name: self.getSharedTripNotifier, object: nil)
                        return
                    }
                    
                    self.downloadImgIndex = 0
                    
                    let ImgPathURL = self.baseURLStr + "sharedTripCoverImg/"
                    
                    var downloadImgName = [String]()
                    
                    for i in 0...getFeedback.count-1 {
                        
                        let sharedTrip:tripData = tripData()
                        
                        sharedTrip.tripName = getFeedback[i]["tripName"] as? String
                        
                        sharedTrip.days = getFeedback[i]["tripDays"] as? Int
                        
                        sharedTrip.country = getFeedback[i]["tripCountry"] as? String
                        
                        sharedTrip.ownerUser = getFeedback[i]["ownerUser"] as? String
                        
                        guard let coverImgName = getFeedback[i]["coverImg"] as? String else {
                            
                            downloadImgName.append("noImg")
                            continue
                        }
                        
                        downloadImgName.append(coverImgName)
                        
                        self.sharedData.sharedTrips?.append(sharedTrip)
                    }
                
                    self.downloadCoverImg(filePath: ImgPathURL, type: self.SHAREDTRIP, imgName: downloadImgName)
                
                
                case .failure(_):
                    print("Server feedback fail")
            }
            
            NotificationCenter.default.post(name: self.getSharedTripNotifier, object: nil)
        }
    }
    
    /**
     Download cover image from server, private function
     */
    private func downloadCoverImg(filePath: String, type: String, imgName: Array<String>) {
        
        
        // thread locked
        threadKey.lock()
        
//        guard self.downloadImgIndex <= imgName.count - 1 else {
//            
//            // thread unlocked
//            threadKey.unlock()
//            return
//        }
        
        for i in 0...imgName.count-1 {
            
            guard let fullImgName = (filePath + imgName[i]).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
                
                // thread unlocked
                threadKey.unlock()
                return
            }
            
            Alamofire.request(fullImgName).responseData { response in
                debugPrint(response)
                print("Is download cover image post success: \(response.result.isSuccess)")
                print("Response: \(String(describing: response.result.value))")
                
                switch(response.result) {
                    
                case .success(_):
                    
                    guard let getImg = response.data else {
                        return
                    }
                    
                    if type == self.POCKETTRIP {
                        
                        self.sharedData.pocketTrips?[i].coverImg = UIImage(data:getImg)
                        
                    } else if type == self.SHAREDTRIP {
                        
                        self.sharedData.sharedTrips?[i].coverImg = UIImage(data:getImg)
                        
                    }
                    
                case .failure(_):
                    print("Server feedback fail")
                }
            }
        }
        
        NotificationCenter.default.post(name: self.downloadCoverImgNotifier, object: nil)
        
        // thread unlocked
        self.threadKey.unlock()
    }
    
    /**
     Download user pocket spot from server
     */
    func getPocketSpotFromServer() {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     REQUEST_KEY: DOWNLOAD_POCKETSPOT_REQ]
        
        
        Alamofire.request(baseURLStr + dataDownloadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is download pocket spot post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? [Dictionary<String,Any>] else {
                        NotificationCenter.default.post(name: self.getPocketSpotNotifier, object: nil)
                        return
                    }
                    
                    for i in 0...getFeedback.count-1 {
                        
                        let spot:spotData = spotData()
                        
                        spot.spotName = getFeedback[i]["spotName"] as? String
                        spot.spotCountry = getFeedback[i]["spotCountry"] as? String
                        spot.placeID = getFeedback[i]["placeID"] as? String
                        
                        
                        self.sharedData.pocketSpot?.append(spot)
                    }
                    
                case .failure(_):
                    print("Server feedback fail")
            }
            
            NotificationCenter.default.post(name: self.getPocketSpotNotifier, object: nil)
        }
    }
    
    /**
     Download user shared trip spot from server
     */
    func getTripSpotFromServer(selectTrip:tripData, req:String) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: selectTrip.ownerUser! as Any,
                                     TRIPNAME_KEY: selectTrip.tripName! as Any,
                                     REQUEST_KEY: req]
        
        Alamofire.request(baseURLStr + dataDownloadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is download shared trip spot post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            
            switch(response.result) {
                
            case .success(let json):
                
                guard let getFeedback = json as? [Dictionary<String,Any>] else {
                    NotificationCenter.default.post(name: self.getTripSpotNotifier, object: nil)
                    return
                }
                
                self.sharedData.tempTripData?.country = selectTrip.country
                self.sharedData.tempTripData?.ownerUser = selectTrip.ownerUser
                self.sharedData.tempTripData?.coverImg = selectTrip.coverImg
                self.sharedData.tempTripData?.days = selectTrip.days
                self.sharedData.tempTripData?.tripName = selectTrip.tripName
                
                for i in 0...getFeedback.count-1 {
                    
                    let getSpot = tripSpotData()
                    
                    getSpot.belongTripName = (getFeedback[i]["tripName"] as? String)!
                    getSpot.nDays = (getFeedback[i]["nDay"] as? Int)!
                    getSpot.nTh = (getFeedback[i]["nth"] as? Int)!
                    getSpot.trafficToNextSpot = (getFeedback[i]["trafficToNext"] as? String)!
                    getSpot.spotName = (getFeedback[i]["spotName"] as? String)!
                    getSpot.placeID = (getFeedback[i]["placeID"] as? String)!
//                    getSpot.spotCountry = (getFeedback[i]["spotCountry"] as? String)!
                    
                    self.sharedData.tempTripData?.spots.append(getSpot)
                }
                
            case .failure(_):
                print("Server feedback fail")
            }
            
            NotificationCenter.default.post(name: self.getTripSpotNotifier, object: nil)
        }
        
        
    }
    
    /**
     Upload pocket spot to server
     */
    func uploadPocketSpotToServer(spotData:spotData) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     SPOTNAME_KEY: spotData.spotName as Any,
                                     SPOTCOUNTRY_KEY: spotData.spotCountry as Any,
                                     PLACEID_KEY: spotData.placeID as Any,
                                     REQUEST_KEY: UPLOAD_POCKETSPOT_REQ]
        
        
        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is upload pocket spot post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? Dictionary<String,Any> else {
                        return
                    }
                    
                    let result = getFeedback["result"] as! Bool
                    
                    let error = getFeedback["errorCode"] as! String
                    
                    print("Result: \(result), Error code:", error)
                    
                case .failure(_):
                    print("Server feedback fail")
            }
        }
    }

    /**
     Upload a shared trip to server, including spot in trip and cover image
     */
    func uploadSharedTripToServer(tripData:tripData) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     TRIPNAME_KEY: tripData.tripName! as Any,
                                     TRIPDAYS_KEY: tripData.days as Any,
                                     TRIPCOUNTRY_KEY: tripData.country! as Any,
                                     REQUEST_KEY: UPLOAD_SHAREDTRIP_REQ]
        
        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is upload shared trip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? Dictionary<String,Any> else {
                        return
                    }
                    
                    let result = getFeedback["result"] as! Bool
                    
                    let error = getFeedback["errorCode"] as! String
                    
                    print("Result: \(result), Error code:", error)
                
                    if result {
                        
                        self.uploadTripCoverImgToServer(tripData: tripData, Req: self.UPLOAD_SHAREDTRIPCOVER_REQ)
                        
//                        self.uploadIndex = tripData.spots.count
                        
                        self.uploadTripSpotToServer(tripData: tripData, request: self.UPLOAD_SHAREDTRIPSPOT_REQ)
                    }                    
                    
                case .failure(_):
                    print("Server feedback fail")
            }
        }
    }
    
    /**
     Upload a pocket trip to server, including spot in trip and cover image
     */
    func uploadPocketTripToServer(tripData:tripData) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     TRIPNAME_KEY: tripData.tripName! as Any,
                                     TRIPDAYS_KEY: tripData.days! as Any,
                                     TRIPCOUNTRY_KEY: tripData.country! as Any,
                                     REQUEST_KEY: UPLOAD_POCKETTRIP_REQ]
        
        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is upload pocket trip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            switch(response.result) {
                
                case .success(let json):
                    
                    guard let getFeedback = json as? Dictionary<String,Any> else {
                        return
                    }
                    
                    let result = getFeedback["result"] as! Bool
                    
                    let error = getFeedback["errorCode"] as! String
                    
                    print("Result: \(result), Error code:", error)
                    
                    if result {
                        
                        self.uploadTripCoverImgToServer(tripData: tripData, Req: self.UPLOAD_POCKETTRIPCOVER_REQ)
                        
//                        self.uploadIndex = tripData.spots.count
                        
                        self.uploadTripSpotToServer(tripData: tripData, request: self.UPLOAD_POCKETTRIPSPOT_REQ)
                    }
                    
                case .failure(_):
                    print("Server feedback fail")
            }
        }
    }
    
    /**
     Upload cover image to server, private function
     */
    private func uploadTripCoverImgToServer(tripData:tripData, Req:String) {
        
        let imageData = UIImageJPEGRepresentation(tripData.coverImg!, 0.5)!
            
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "coverImg", fileName: "tripCover.jpeg", mimeType: "file/jpeg")
                multipartFormData.append(self.sharedData.memberData!.account!.data(using: String.Encoding.utf8)!, withName: self.USER_NAME_KEY)
                multipartFormData.append(tripData.tripName!.data(using: String.Encoding.utf8)!, withName: self.TRIPNAME_KEY)
                multipartFormData.append(Req.data(using: String.Encoding.utf8)!, withName: self.REQUEST_KEY)
                
        },
            to: baseURLStr + coverImgUploadURLstr,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        
                        debugPrint(response)
                        
                        print("Is upload pocket trip cover img post success: \(response.result.isSuccess)")
                        print("Response: \(String(describing: response.result.value))")
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )        
    }
    
    /**
     Upload a trip spot to server, this function would be call until all of trip spot has been upload, private function
     */
    private func uploadTripSpotToServer(tripData:tripData, request:String) {
        
        // thread locked
        threadKey.lock()
        
//        uploadIndex -= 1
//        
//        guard uploadIndex >= 0 else {
//            
//            // thread unlocked
//            threadKey.unlock()
//            
//            uploadIndex = 0
//            return
//        }
        
        for i in 0..<tripData.spots.count {
            
            // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
            let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                         TRIPNAME_KEY: tripData.spots[i].belongTripName as Any,
                                         SPOTNAME_KEY: tripData.spots[i].spotName! as Any,
                                         NDAY_KEY: tripData.spots[i].nDays as Any,
                                         NTH_KEY: tripData.spots[i].nTh as Any,
                                         TRAFFICTITLE_KEY: tripData.spots[i].trafficTitle as Any,
                                         TRAFFIC_KEY: tripData.spots[i].trafficToNextSpot as Any,
                                         PLACEID_KEY: tripData.spots[i].placeID as Any,
                                         REQUEST_KEY: request]
            
            Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseJSON { response in
                
                debugPrint(response)
                print("Upload request: \(request)")
                print("Is upload trip spot post success: \(response.result.isSuccess)")
                print("Total count in spot array: \(String(tripData.spots.count))")
//                print("Upload index in spot array: \(String(self.uploadIndex))")
                print("Response: \(String(describing: response.result.value))")
            }
        }
        
        // thread unlocked
        self.threadKey.unlock()
    }
    
    /**
     Delete pocket spot from server
     */
    func deletePocketSpotFromServer(spotName:String) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     SPOTNAME_KEY: spotName,
                                     REQUEST_KEY: DELETE_POCKETSPOT_REQ]
        
        
        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is delete pocket spot post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
            
            switch(response.result) {
                
            case .success(let json):
                
                guard let getFeedback = json as? Dictionary<String,Any> else {
                    return
                }
                
                let result = getFeedback["result"] as! Bool
                
                let error = getFeedback["errorCode"] as! String
                
                print("Result: \(result), Error code:", error)
                
            case .failure(_):
                print("Server feedback fail")
            }
        }
    }
    
    /**
     Delete user pocket trip from server, trip spot and cover image would also be delete from server
     */
    func deletePocketTripFromServer(tripName:String) {
        
        // 一定要解包，否則php端讀到的$_POST內容會帶有"Option"這個字串而導致判斷出問題
        let parameters:Parameters = [USER_NAME_KEY: sharedData.memberData!.account! as Any,
                                     TRIPNAME_KEY: tripName,
                                     REQUEST_KEY: DELETE_POCKETTRIP_REQ]
        
        
        Alamofire.request(baseURLStr + dataUploadURLstr, method: .post, parameters: parameters).responseJSON { response in
            
            debugPrint(response)
            print("Is delete pocket trip post success: \(response.result.isSuccess)")
            print("Response: \(String(describing: response.result.value))")
        }
    }
    
}
