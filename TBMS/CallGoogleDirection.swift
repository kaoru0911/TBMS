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
    private let parametersSetting = DirectParametersAndRequestURLGenerator()
    private var requestURL : String!
    
    var route : LegsData!
    
    //設定預設參數
    init( responseFormat : RespondsDataType = .json,
          language : LanguageSetting = .chinese,
          travelMod : TravelMod = .driving,
          distanceUnit : DistanceUnit = .metric,
          departureTime : String = "1495004263" ) {
        
        super.init()
        // Setting parameters
        parametersSetting.outputFormat = responseFormat
        parametersSetting.language = language
        parametersSetting.travelMod = travelMod
        parametersSetting.distanceUnit = distanceUnit
        parametersSetting.departureTime = departureTime
        parametersSetting.transitModePreference = TransitPreferences(bus: true, subway: true, train: true, tram: true, rail: true).modeSetting
        self.requestURL = parametersSetting.urlStringWithRespondType()
    }
    
    func getRouteInformation (origin : String, destination : String, completion: @escaping (_ route:ResponceRouteType)->Void ) {
        
        // Generate parameters dictionary & url
        var originString : String
        var destinationString : String
        originString = "place_id:" + origin
        destinationString = "place_id:" + destination
        let parameters = parametersSetting.produceParameterDictionary(origin: originString, destination: destinationString)
        
        Alamofire.request(requestURL, method: .get, parameters: parameters).responseJSON{ response in
            // Check the response status
            if let result = response.result.value {
                let responseJSON = JSON(result)
                guard responseJSON["status"] == "OK" else{
                    completion(self.route)
                    return
                }
                let parser = DirectionJsonAnalyst()
                self.route = parser.trasferJSONToObject(responseJSON: responseJSON,travelMode:self.parametersSetting.travelMod.rawValue)
                completion(self.route)
            }
        }
    }
}

