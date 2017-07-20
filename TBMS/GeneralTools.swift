//
//  GeneralTools.swift
//  TBMS
//
//  Created by 倪僑德 on 2017/6/13.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import Foundation
import GooglePlacePicker


class GeneralToolModels {
    
    private let server = ServerConnector()
    private let shareData: DataManager = .shareDataManager
    fileprivate let getPocketSpotAfterLoginNotifier = Notification.Name(NotificationName.getPocketSpotAfterLoginNotifier.rawValue)
    
    static let generalColorSetting = [UIColor(red: 177/255, green: 143/255, blue: 106/255, alpha: 1),
                               UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1),
                               UIColor(red: 145/255, green: 168/255, blue: 205/255, alpha: 1),
                               UIColor(red: 247/255, green: 202/255, blue: 201/255, alpha: 1),
                               UIColor(red: 3/255, green: 79/255, blue: 132/255, alpha: 1),
                               UIColor(red: 251/255, green: 227/255, blue: 55/255, alpha: 1),
                               UIColor(red: 247/255, green: 120/255, blue: 107/255, alpha: 1)]
    
    func chooseCoverImg(selectedCountry: String) -> UIImage {
        
        let countryName = selectedCountry + "img.jpg"
        
        guard let image = UIImage(named: countryName) else {
            print("沒圖片唷")
            let imageBlank = UIImage()
            return imageBlank
        }
        return image
    }
    
    func selectCountryTypeTrasformer(selectedCountry: String) -> BoundsCoordinate! {
        
        let countryList: [String: BoundsCoordinate] = ["台灣":.臺灣,"日本":.日本,"香港":.香港,"韓國":.韓國,"中國":.中國,
                                                       "新加坡":.新加坡,"泰國":.泰國,"菲律賓":.菲律賓,
                                                       "英國":.英國,"法國":.法國,"德國":.德國,"西班牙":.西班牙,
                                                       "瑞士":.瑞士,"冰島":.冰島,"芬蘭":.芬蘭,"義大利":.義大利,
                                                       "美國":.美國,"加拿大":.加拿大,
                                                       "委內瑞拉":.委內瑞拉,"巴西":.巴西,"阿根廷":.阿根廷,
                                                       "澳大利亞":.澳洲,"紐西蘭":.新西蘭 ]
        
        let country = countryList[selectedCountry]
        return country!
    }
    
    
    func customActivityIndicatory(_ viewContainer: UIView, startAnimate:Bool? = true) {
        
        // 做一個透明的view來裝
        guard let frame = viewContainer.superview?.frame else { return }
        
        let mainContainer = UIView(frame: frame)
        mainContainer.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
        // background的alpha跟view的alpha不同
        mainContainer.alpha = 0.3
        //================================
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = true
        
        //創一個手勢在這個view裡面
        let touch = UITapGestureRecognizer(target: self, action: nil)
        mainContainer.addGestureRecognizer(touch)
        
        // 旋轉圈圈放在這個view上
        let viewBackgroundLoading = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = CGPoint(x: mainContainer.frame.width/2,
                                               y: mainContainer.frame.height/2)
        //        viewBackgroundLoading.backgroundColor = UIColor(red:0x7F, green:0x7F, blue:0x7F, alpha: 1)
        viewBackgroundLoading.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 1)
        //================================
        //        viewBackgroundLoading.alpha = 0.5
        //================================
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        // 創造旋轉圈圈
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }   
    }
    
    
    // MARK: Alert Preparation Funtions.
    func prepareCommentAlertVC(title: String, message: String!, cancelBtnTitle: String = "確定") -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: cancelBtnTitle, style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        return alert
    }
    
    
    func prepareUnloginAlertVC( title: String,
                                message: String!,
                                segueID: String,
                                targetVC: UIViewController,
                                cancelBtnTitle: String = "取消",
                                confirmBtnTitle: String = "登入" ) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: cancelBtnTitle, style: .cancel, handler: nil)
        let login = UIAlertAction(title: confirmBtnTitle, style: .destructive) { (login) in
        
            self.loginAlertAction(targetVC: targetVC, segueID: segueID)
        }
        
        alert.addAction(cancel)
        alert.addAction(login)
        
        return alert
    }
    
    
    private func loginAlertAction(targetVC: UIViewController?, segueID: String) {
        
        guard let vc = targetVC else {
            print("NOTE: UIVC doesn't exist.")
            return
        }
        
        guard shareData.chooseCountry != "" else {
            print("ERROR: Selected country unknown.")
            return
        }
        
        guard let owner = shareData.memberData?.account else {
            print("ERROR: User account unknown")
            return
        }
        
//        NotificationCenter.default.addObserver(vc,
//                                               selector: #selector(loginAndGetPocketSpotNotifierDidGet(notification:)),
//                                               name: self.getPocketSpotAfterLoginNotifier,
//                                               object: nil)
//        
        vc.performSegue(withIdentifier: segueID, sender: vc)
    }
    
    func getPreviousVCinNavigationVC(selfVC: UIViewController, distanceIndex: Int?, tagetVcClass: NSObject? = nil ) -> UIViewController? {
        
        guard let vcs = selfVC.navigationController?.viewControllers else {
            print("ERROR:Navigation VC doesn't exist")
            return nil
        }
        
        
        if let distanceIndex = distanceIndex {
            
            guard let index = vcs.index(of: selfVC) else {
                print("ERROR: The vc doesn't exist in its Navigation vc.")
                return nil
            }
            
            let tagetVcIndex = index - distanceIndex
            
            guard tagetVcIndex >= 0 else {
                print("ERROR: Target index is out of range")
                return nil
            }
            
            return vcs[tagetVcIndex]
           
        } else {
            return nil
        }
    }
    
    // MARK: Debug Funtions
    func printAllAttractionsDetailToDebug(attractions: [Attraction]?, debugTitle: String) {
        
        print(debugTitle)
        
        guard let attractions = attractions else {
            print("ERROR: The Attractions array is nil!")
            return
        }
        
        guard attractions.isEmpty != true else {
            print("WARNING: The attractions array is empty!")
            return
        }
        
        print("--Attraction Debug:-----------------------")
        for attraction in attractions {
            let name = attraction.attrctionName ?? "none"
            let addr = attraction.address ?? "none"
            let placeId = attraction.placeID ?? "none"
            let latCoord = attraction.coordinate?.latitude ?? 0.0
            
            print(" name: \(name).\n addr: \(addr).\n placeId: \(placeId).\n latCoordinate: \(latCoord)")
        }
        print("------------------------------------------")
    }
    
    func printAllSpotsDetailToDebug(spots: [spotData]?, debugTitle: String) {
        
        print(debugTitle)
        
        guard let spots = spots else {
            print("ERROR: The Attractions array is nil!")
            return
        }
        
        guard spots.isEmpty != true else {
            print("WARNING: The spots array is empty!")
            return
        }
        
        print("--Spot Debug:-----------------------------")
        for spot in spots {
            let name = spot.spotName ?? "none"
            let addr = spot.spotAddress ?? "none"
            let placeId = spot.placeID ?? "none"
            let latCoord = spot.latitude ?? 0.0
            
            print(" name: \(name).\n addr: \(addr).\n placeId: \(placeId).\n latCoordinate: \(latCoord)")
        }
        print("------------------------------------------")
    }
    
    func printCellTripDataDetails(tripData: tripData?) {
        
        guard let trip = tripData else {
            print("ERROR: tripData is nil.")
            return
        }
        
        print("TRIPLISTTEST: \(trip.ownerUser ?? "nothing exist")!!!!")
        print("TRIPLISTTEST: \(trip.country ?? "nothing exist")!!!!")
        print("TRIPLISTTEST: \(trip.tripName ?? "nothing exist")!!!!")
        print("TRIPLISTTEST: \(trip.days ?? 0)!!!!")
    }
}



enum BoundsCoordinate: String {
    
    case 香港 = "22.2768196,114.1681163,16z",
    日本 = "35.668864,139.4611935,10z",
    韓國 = "37.5647689,126.7093638,10z",
    中國 = "39.9375346,115.837023,9z",
    臺灣 = "25.0498002,121.5363940,11z",
    新加坡 = "1.3122663,103.8353844,12.73z",
    泰國 = "13.7244426,100.3529157,10z",
    菲律賓 = "14.5964879,120.9094042,12z",
    英國 = "51.528308,-0.3817961,10z",
    法國 = "48.8587741,2.2074741,11z",
    德國 = "59.3258414,17.7073729,10z",
    西班牙 = "40.4378698,-3.8196207,11z",
    瑞士 = "46.9545845,7.2547869,11z",
    冰島 = "64.1322134,-21.9925226,11z",
    芬蘭 = "60.1637088,24.7600957,10z",
    義大利 = "41.9097306,12.2558141,10z",
    美國 = "38.8993276,-77.0847778,12z",
    加拿大 = "45.2487862,-76.3606792,9z",
    委內瑞拉 = "10.4683612,-67.0304525,11z",
    巴西 = "-15.6936233,-47.9963963,10.25z",
    阿根廷 = "-34.6156541,-58.5734051,11z",
    澳洲 = "-35.2813043,149.1204446,15z",
    新西蘭 = "-41.2442852,174.6217707,11z"
}

enum Space {
    case positive, negative
}

enum NotificationName: String {
    
    case pocketSpotTVCDisappear
    
    case loginNotifier
    case getPocketTripNotifier
    case getPocketSpotNotifier
    case getPocketSpotAfterLoginNotifier
    case downloadCoverImgNotifier
    case connectServerFail
    
    case uploadPocketSpotNotifier
    case uploadCoverImgNotifier
   
    case deletePocketSpotNotifier
    case deletePocketTripNotifier

}

