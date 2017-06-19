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
import MapKit

class GoogleDirectionCaller: NSObject {
    
    let parametersSetting = DirectParametersAndRequestURLGenerator()
    var route : LegsData!
    
    private var requestURL : String!
    private let jsonObjector = DirectionJsonAnalyst()
    
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
        
        // Setting parameters
        parametersSetting.outputFormat = responseFormat
        parametersSetting.language = language
        parametersSetting.travelMod = travelMod
        parametersSetting.distanceUnit = distanceUnit
        parametersSetting.departureTime = departureTime
        parametersSetting.transitModePreference = TransitPreferences(bus: true,
                                                                     subway: true,
                                                                     train: true,
                                                                     tram: true,
                                                                     rail: true).modeSetting
        self.requestURL = parametersSetting.urlStringWithRespondType()
    }
    
    
    func getRouteInformation (origin: Attraction,
                              destination: Attraction,
                              completion: @escaping ( _ routeInformation:LegsData) -> Void ) {
        
        // Generate parameters dictionary & url
        let originString = "place_id:" + origin.placeID
        let destinationString = "place_id:" + destination.placeID
        let parameters = parametersSetting.produceParameterDictionary(origin: originString,
                                                                      destination: destinationString)
        
        //----for debug-----
        print("travelMode=\(parametersSetting.travelMod)")
        let testURL = produceRequestURLForTest(urlString: requestURL, parameters: parameters)
        print("test URL:/n\(testURL)")
        //--------------
        
        Alamofire.request(requestURL, method: .get, parameters: parameters).responseJSON{ response in
            
            // Check the response status
            if let result = response.result.value {
                
                let responseJSON = JSON(result)
                
                if responseJSON["status"] == "OK" {

                    let parser = DirectionJsonAnalyst()
                    let route = parser.trasferJSONToObject(responseJSON: responseJSON,travelMode:self.parametersSetting.travelMod.rawValue)!
                    completion(route)

                } else {
                    
                    self.getRouteInformationByMapKitETA(originCoord: origin.coordinate, destinationCoord: destination.coordinate, completion: completion)
                }
            }
        }
    }
    
    
    private func produceRequestURLForTest (urlString:String, parameters:[String:String]) -> String {
        
        var string = urlString
        
        for obj in parameters {
            let tmpString = "\(obj.key)=\(obj.value)&"
            string += tmpString
        }
        string.characters.removeLast()
        
        return string
    }
    
    
    private func getRouteInformationByMapKit(originCoord: CLLocationCoordinate2D,
                                     destinationCoord: CLLocationCoordinate2D,
                                     completion: @escaping ( _ routeInformation:LegsData) -> Void ) {
        
//        print("近來mapKit囉")
        // setting the request detail about getting travelTime
        let request = MKDirectionsRequest()
        request.transportType = .transit
        
        request.source = MKMapItem(placemark:(MKPlacemark(coordinate: originCoord)))
        request.destination = MKMapItem(placemark: (MKPlacemark(coordinate: destinationCoord)))
        
        let direction = MKDirections(request: request)
        
        direction.calculate { (response, error) in
            
            guard error == nil else{
                print("error:\n\(error.debugDescription)")
                self.routeError(completion: completion)
                return
            }
            
            guard let result = response else{
                print("response is nil")
                self.routeError(completion: completion)
                return
            }
            
            let route = result.routes[0]
            var travelTime: String {
                get{
                    var timeString = "少於 1 分鐘"
                    let time = Int(route.expectedTravelTime)/60
                    if time > 1{
                        timeString = "\(time) 分鐘"
                    }
                    return timeString
                }
            }
            
            let legsData = LegsData()
            legsData.duration = travelTime
            legsData.steps = [StepsData]()
            
            for step in route.steps {
                let stepData = StepsData()
                stepData.htmlInstructions = step.instructions
                legsData.steps.append(stepData)
            }
            
            completion(legsData)
//            print("離開mapKit囉")
        }
    }
    
    private func getRouteInformationByMapKitETA(originCoord: CLLocationCoordinate2D,
                                             destinationCoord: CLLocationCoordinate2D,
                                             completion: @escaping ( _ routeInformation:LegsData) -> Void ) {
        
//        print("近來mapKitETA囉")
        // setting the request detail about getting travelTime
        let request = MKDirectionsRequest()
        request.transportType = .transit
        
        request.source = MKMapItem(placemark:(MKPlacemark(coordinate: originCoord)))
        request.destination = MKMapItem(placemark: (MKPlacemark(coordinate: destinationCoord)))
        
        let direction = MKDirections(request: request)
        
        direction.calculateETA(completionHandler: { (response, error) in
            
//            print("近來calculateETA囉")
            guard error == nil else{
                print("error:\n\(error.debugDescription)")
                self.routeError(completion: completion)
                return
            }
            
            guard let result = response else{
                print("response is nil")
                self.routeError(completion: completion)
                return
            }
            
            var travelTime: String {
                get{
                    var timeString = "少於 1 分鐘"
                    let time = Int((result.expectedTravelTime)/60)
                    if time > 1{
                        timeString = "\(time) 分鐘"
                    }
                    return timeString
                }
            }
            
//            print("開始給值囉")
            let legsData = LegsData()
            legsData.duration = travelTime
            
            let tmpStep = StepsData()
            tmpStep.htmlInstructions = "大眾運輸, \(travelTime). \n (詳情請見導航)"
            tmpStep.travelMode = TravelMod.transit
            legsData.steps = [tmpStep]
            
//            print(legsData.duration)
            for step in legsData.steps {
                print(step.htmlInstructions)
            }
//            print("準備completion")
            completion(legsData)
        })
    }
    
    private func routeError(completion: @escaping ( _ routeInformation:LegsData) -> Void) {
        let route = LegsData()
        completion(route)
    }
}

