//
//  DataManager.swift
//  TravelByMyself
//
//  Created by popcool on 2017/5/9.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    static var shareDataManager:DataManager = DataManager()    
    
    var memberData:MemberData?
    var pocketTrips:Array<tripData>?
    var sharedTrips:Array<tripData>?
    var menuCountries:Array<countryData> = []
    var chooseCountry:String = ""
    var pocketSpot:Array<spotData>?
    var isLogin:Bool!
    
    // 將init設為private，以免外部去調用到
    private override init() {
        
        super.init()
        
        // test===================
        let trip:tripData = tripData()
        let spot_1:tripSpotData = tripSpotData()
        let spot_2:tripSpotData = tripSpotData()
        let spot_3:tripSpotData = tripSpotData()
        let spot_4:tripSpotData = tripSpotData()
        
        spot_1.spotName = "清水寺"
        spot_1.trafficToNextSpot = "十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉"
        spot_1.belongTripName = "日本五日遊"
        spot_1.nDays = 1
        spot_1.nTh = 1
        
        spot_2.spotName = "平等院"
        spot_2.trafficToNextSpot = "十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉，換五號公車乘坐到金閣寺站，下車向東行三十公尺"
        spot_2.belongTripName = "日本五日遊"
        spot_2.nDays = 2
        spot_2.nTh = 2
        
        spot_3.spotName = "金閣寺"
        spot_3.trafficToNextSpot = "十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉，換地鐵三號線至天龍人站，向東行五十公尺後右轉，直行二十公尺"
        spot_3.belongTripName = "日本五日遊"
        spot_3.nDays = 3
        spot_3.nTh = 3
        
        spot_4.spotName = "天龍寺"
        spot_4.trafficToNextSpot = ""
        spot_4.belongTripName = "日本五日遊"
        spot_4.nDays = 4
        spot_4.nTh = 4
        //=====================
        
        
        memberData = MemberData()
        pocketTrips = []
        sharedTrips = []
        menuCountries = []
        pocketSpot = []
        isLogin = false
        
        // test==================
        trip.spots.append(spot_1)
        trip.spots.append(spot_2)
        trip.spots.append(spot_3)
        trip.spots.append(spot_4)
        trip.tripName = "日本五日遊"
        trip.days = 5
        trip.country = "日本"
        trip.coverImg = UIImage(named: "Kyoto")!
        
        memberData?.account = "create"
        memberData?.password = "ddd"
        memberData?.email = "ppp.gmail.com"
        
        pocketTrips?.append(trip)
        sharedTrips?.append(trip)
        // ======================
        
    }
}

// 公開class，給外部調用來創造景點
class spotData: NSObject {
    
    var spotName:String?
    var spotImg:UIImage?
    var spotInfo:String?
}

class tripSpotData: spotData {
    
    var trafficTitle:String = ""
    var trafficImage:[UIImage]?
    var trafficToNextSpot:String = ""
    var belongTripName:String = ""
    var nDays:Int = 1
    var nTh:Int = 0
}

class tripData: NSObject {
    
    var tripName:String?
    var country:String?
    var days:Int?
    var coverImg:UIImage?
    var spots = [tripSpotData]()
}

class sharedTripData: tripData {
    
    var popularStars:Int?
}

class countryData: NSObject {
    
    var countryName:String?
    var countryFlag:UIImage?
}

class MemberData: NSObject {
    
    var account:String?
    var password:String?
    var email:String?
}



