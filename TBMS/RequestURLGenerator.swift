//
//  RequestURLGenerator.swift
//  AlamofireSimpleDemo
//
//  Created by 倪僑德 on 2017/5/4.
//  Copyright © 2017年 Chiao. All rights reserved.
//

/*
 Model主要功能：
    1. 產生Alamofire需要的parameters dictionary
 待修正部分：
    1. transitModePreference部分應改成func直接產生, not產生物件讀取property
*/


import UIKit

/// To Produce a parameter dictionary & urlString to Alamofire, you can change the parameters by change the value in this class
class DirectionParameterSettingAndRequestURLGenerator: NSObject {
    
    // String setting.
    private let departureTimeKeyWords = "departure_time"
    
    // Parameters with defaultValue.
    var outputFormat : respondsDataType = .json
    var language : languageSetting = .chinese
    var distanceUnit : distanceUnit = .metric
    var travelMod : travelMod = .transit
    
    // Parameters with transit travelMod.
    var departureTime = "1495004263"
    var transitModePreference = transitPreferences(bus: true, subway: true, train: true, tram: true, rail: true).modeSetting
    var trafficModel : responceTrafficModel = .pessimistic
    
    
    // Setting requestUrl & GoldKey
    var goldKey = "AIzaSyAmmbgbhCNuyLVRmWJIftZ1Z9jDD_1zAkU"
    private let mainURL = "https://maps.googleapis.com/maps/api/directions/"
    private var urlString : String!

    
    /// To Produce a parameter dictionary for Alamofire making request
    ///
    /// - Parameters:
    ///   - origin: origin site (name or address)
    ///   - destination: destination site (name or address)
    /// - Returns: parameters dictionary
    func produceParameterDictionary(origin:String,destination:String) -> [String : String]{
        var parameterArray = ["origin":origin,
                              "destination":destination,
                              "language":language.rawValue,
                              "mode":travelMod.rawValue,
                              "units":distanceUnit.rawValue,
                              "traffic_model":trafficModel.rawValue,
                              "transit_mode":transitModePreference!,
                              /*"avoid":avoid,*/
                              "key":goldKey]
        
        // if traffic_model setting is exist, departurTime setting is 
        if parameterArray["traffic_model"] != "" {
            parameterArray.updateValue(departureTime, forKey: departureTimeKeyWords)
        }
        
        let tmpArray = parameterArray.filter { $0.value != ""}
        parameterArray.removeAll()
        for tmpObj in tmpArray {
            parameterArray[tmpObj.key] = tmpObj.value
        }
        return parameterArray
    }
    
    /// Combine urlString and response type(json/xml) to produce a requestURL for Alamofire making request
    ///
    /// - Returns: urlString
    func urlStringWithRespondType() -> String {
        urlString = "\(mainURL)\(outputFormat)?"
        return urlString
    }
}


//設定回傳資料方式
enum respondsDataType : String{ //直接寫
    case json = "json"
    case xml = "xml"
}
//設定回傳語言
enum languageSetting : String { //&language=
    case chinese = "zh-TW"
    case english = "en"
    case defaultValue = ""
}
//設定旅遊型態
enum travelMod : String {  //&mod=
    //&traffic_model= 指定偏好方式
    case driving = "driving"
    case walking = "walking"
    case bike = "bicycling"
    case transit = "transit"
    case defaultValue = ""
}
//設定距離單位
enum distanceUnit : String { //&units=
    case metric = "metric"
    case imperial = "imperial"
    case defaultValue = ""
}
//設定路線回傳模式
enum responceTrafficModel : String {
    case bestGuess = "best_guess"   //指出傳回的 duration_in_traffic 應該是考量歷史路況與即時路況下的最佳預估旅行時間。departure_time 越接近現在，即時路況就越重要。
    case pessimistic = "pessimistic" //指出傳回的 duration_in_traffic 應該比過去大部分的實際旅行時間更久，雖然偶有路況特別壅塞而超過此值的日子。
    case optimistic = "optimistic"   //指出傳回的 duration_in_traffic 應該比過去大部分的實際旅行時間更短，雖然偶有路況特別順暢而比此值更快的日子。
    case defaultValue = ""
}
//設定要避開的
enum avoidPathType : String {   //avoid=
    case tolls = "tolls"    //指出計算的路線應該避開收費道路/橋樑。
    case highways = "highways"  //指出計算的路線應該避開高速公路。
    case ferries = "ferries"    //指出計算的路線應該避開渡輪。
    case indoor = "indoor"  //指出計算的路線應該避開有室內臺階的步行與大眾運輸路線。
    case none = ""
}

//設定偏好大眾運輸模式
class transitPreferences {
    
    //optional setting
    private var bus = (false,"bus")
    private var subway = (false,"subway")
    private var train = (false,"train")
    private var tram = (false,"tram")
    private var rail = (false,"rail")
    var modeSetting : String!
    
    //-----------注意：有點醜, 待修改------------
    init(bus:Bool=false, subway:Bool=false, train:Bool=false, tram:Bool=false, rail:Bool=false) {
        
        self.bus.0 = bus
        self.subway.0 = subway
        self.train.0 = train
        self.tram.0 = tram
        self.rail.0 = rail
        let modeOptionArray = [self.bus.0,
                               self.subway.0,
                               self.train.0,
                               self.tram.0,
                               self.rail.0]
        
        let modeStringArray = [self.bus.1,
                               self.subway.1,
                               self.train.1,
                               self.tram.1,
                               self.rail.1]
        
        modeSetting = produceTransitModeString(modStringArray: modeStringArray, modOptionArray: modeOptionArray)
    }
    
    //create the String of requestParameters
    private func produceTransitModeString(modStringArray : [String], modOptionArray:[Bool]) -> String {
        var modeSettingString = ""
        for i in 0...modStringArray.count-1 {
            if modOptionArray[i] {
                modeSettingString += "|\(modStringArray[i])"
            }
        }
        if modeSettingString.characters.first == "|"{
            modeSettingString.characters.removeFirst()
        }
        return modeSettingString
    }
}
