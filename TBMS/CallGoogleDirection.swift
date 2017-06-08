//
//  FindTrafficTimeAndWay.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/20.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class GoogleDirectionCaller: NSObject {
    
    private let jsonObjector = DirectionJsonAnalyst()
    private var requestURL : String!
    let parametersSetting = DirectParametersAndRequestURLGenerator()
    
    var route : LegsData!
    
    //設定預設參數
    init( responseFormat : RespondsDataType = .json,
          language : LanguageSetting = .chinese,
          travelMod : TravelMod = .walking,
          distanceUnit : DistanceUnit = .metric,
          departureTime : String = "" ) {
        
        super.init()
        // setting departureTime
        var firstDate = DateComponents()
        firstDate.year = 1970
        firstDate.month = 1
        firstDate.day = 1
        firstDate.hour = 0
        firstDate.minute = 0
        firstDate.second = 0
        
//        
//        let calendar = Calendar.current
//        let timeSpace = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: )
        
        // Setting parameters
        parametersSetting.outputFormat = responseFormat
        parametersSetting.language = language
        parametersSetting.travelMod = travelMod
        parametersSetting.distanceUnit = distanceUnit
        parametersSetting.departureTime = departureTime
        parametersSetting.transitModePreference = TransitPreferences(bus: true, subway: true, train: true, tram: true, rail: true).modeSetting
        self.requestURL = parametersSetting.urlStringWithRespondType()
    }
    
    func getRouteInformation (origin : String, destination : String, completion: @escaping ( _ routeInformation:LegsData) -> Void ) {
        
        // Generate parameters dictionary & url
        var originString : String
        var destinationString : String
        originString = "place_id:" + origin
        destinationString = "place_id:" + destination
        
        let parameters = parametersSetting.produceParameterDictionary(origin: originString, destination: destinationString)
        //----測試用-----
        print("travelMode=\(parametersSetting.travelMod)")
        let testURL = produceRequestURLForTest(urlString: requestURL, parameters: parameters)
        print(testURL)
        //--------------
        Alamofire.request(requestURL, method: .get, parameters: parameters).responseJSON{ response in
            
            // Check the response status
            if let result = response.result.value {
                let responseJSON = JSON(result)
                guard responseJSON["status"] == "OK" else{
                    let route = LegsData()
                    completion(route)
                    return
                }
                let parser = DirectionJsonAnalyst()
                let route = parser.trasferJSONToObject(responseJSON: responseJSON,travelMode:self.parametersSetting.travelMod.rawValue)!
                completion(route)
            }
        }
    }
    
    func produceRequestURLForTest (urlString:String, parameters:[String:String]) -> String {
        var string = urlString
        for obj in parameters {
            let tmpString = "\(obj.key)=\(obj.value)&"
            string += tmpString
        }
        string.characters.removeLast()
        return string
    }
}

