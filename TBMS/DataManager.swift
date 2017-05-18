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
    var sharedTrips:Array<sharedTripData>?
    var menuCountries:Array<countryData> = []
    var chooseCountry:String = ""
    
    // 將init設為private，以免外部去調用到
    private override init() {
        
        super.init()
        
        // test===================
        var trip:tripData = tripData()
        var spot_1:spotData = spotData()
        var spot_2:spotData = spotData()
        var spot_3:spotData = spotData()
        var spot_4:spotData = spotData()
        
        spot_1.spotName = "清水寺"
        spot_1.trafficToNextSpot = ["十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉"]
        
        spot_2.spotName = "平等院"
        spot_2.trafficToNextSpot = ["十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉，換五號公車乘坐到金閣寺站，下車向東行三十公尺"]
        
        spot_3.spotName = "金閣寺"
        spot_3.trafficToNextSpot = ["十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉，換地鐵三號線至天龍人站，向東行五十公尺後右轉，直行二十公尺"]
        
        spot_4.spotName = "天龍寺"
        spot_4.trafficToNextSpot = [""]
        //=====================
        
        
        memberData = MemberData()
        pocketTrips = []
        sharedTrips = []
        menuCountries = []
        
        trip.spots.append(spot_1)
        trip.spots.append(spot_2)
        trip.spots.append(spot_3)
        trip.spots.append(spot_4)
        
        pocketTrips?.append(trip)
    }
}

// 公開class，給外部調用來創造景點
class spotData: NSObject {
    
    var spotName:String?
    var spotImg:UIImage?
    var spotInfo:String?
    var trafficToNextSpot:[String]?
    var trafficImage:[UIImage]?
}

class tripData: NSObject {
    
    var tripName:String?
    var country:String?
    var days:Int?
    var coverImg:UIImage?
    var spots:Array<spotData> = []
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



