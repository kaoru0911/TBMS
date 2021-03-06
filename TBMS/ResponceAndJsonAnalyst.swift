//
//  ResponceAndJsonAnalyst.swift
//  AlamofireSimpleDemo
//
//  Created by 倪僑德 on 2017/5/8.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit
import SwiftyJSON

/*
 Model主要功能：
 1. 將回傳的JSON資料物件化
 
 未完成部分：
 1. 各物件/屬性註解
 */

/// To transfer JSON type file to object, you can do this by the func trasferJSONToObject.
class DirectionJsonAnalyst: NSObject {
    
    // Dictionary key words setting : Legs
    private let keySteps = "steps"
    private let keyTravelMode = "travel_mode"
    private let keyText = "text"
    private let keyLat = "lat"
    private let keyLng = "lng"
    private let keyDistance = "distance"
    private let keyDuration = "duration"
    private let keyLocation = "location"
    private let keyEndLocation = "end_location"
    private let keyStartLocation = "start_location"
    private let keyStartAddress = "start_address"
    private let keyEndAddress = "end_address"
    private let keyInstructions = "html_instructions"
    private let keyManeuver = "maneuver"
    
    // Dictionary key words setting : Steps
    private let keyName = "name"
    private let keyArrivalStop = "arrival_stop"
    private let keyDepartureStop = "departure_stop"
    private let keyHeadsign = "headsign"
    private let keyHeadway = "headway"
    private let keyNumStops = "num_stops"
    private let keyArrivalTime = "arrival_time"
    private let keyDepartureTime = "departure_time"
    private let keyTransitDetails = "transit_details"
    
    // Dictionary key words setting : transitDetails
    private let keyLine = "line"
    private let keyAgencies = "agencies"
    private let keyColor = "color"
    private let keyShortName = "short_name"
    private let keyVehicle = "vehicle"
    private let keyLocalIcon = "local_icon"
    private let keyIcon = "icon"
    //    let keyTravelMode = "travel_mode"
    
    
    /// To transfer JSON type file to object
    ///
    /// - Parameters:
    ///   - responseJSON: JSON file make by swiftyJSON
    ///   - travelMode: The travel mode in the request you send to google direction
    /// - Returns: Legs datas object
    func trasferJSONToObject(responseJSON:JSON, travelMode:String) -> LegsData? {
        
        // Setting main chain of the Dictionary whitch is transfered from responseJSON
        var legsData = responseJSON["routes"][0]["legs"][0]
        
        // get the content value from JSON
        var distance = legsData[keyDistance][keyText].string!
        var duration = legsData[keyDuration][keyText].string!
        var starLctLat = legsData[keyStartLocation][keyLat].double!
        var starLctlng = legsData[keyStartLocation][keyLng].double!
        var endLctLat = legsData[keyEndLocation][keyLat].double!
        var endLctlng = legsData[keyEndLocation][keyLng].double!
        let strAds = legsData[keyStartAddress].string!
        let endAds = legsData[keyEndAddress].string!
        // create the legs objct with comment content values
        let legs = LegsData()
        legs.produceBasicPathObject( distance: distance,
                                     duration: duration,
                                     strAddress: strAds,
                                     endAddress: endAds,
                                     endLctLat: endLctLat,
                                     endLctLng: endLctlng,
                                     strLctLat: starLctLat,
                                     starLctLng: starLctlng )
        
        // get the legs detail information from JSON and put into the property "steps"
        legs.steps = [StepsData]()
        // get the content value from JSON and put into "step"
        let stepsArray = legsData[keySteps].arrayValue
        for step in stepsArray {
            distance = step[keyDistance][keyText].string!
            duration = step[keyDuration][keyText].string!
            starLctLat = step[keyStartLocation][keyLat].double!
            starLctlng = step[keyStartLocation][keyLng].double!
            endLctLat = step[keyEndLocation][keyLat].double!
            endLctlng = step[keyEndLocation][keyLng].double!
            
            var stepDetail = StepsData()
            stepDetail.produceBasicPathObject( distance: distance,
                                               duration: duration,
                                               strAddress: nil,
                                               endAddress: nil,
                                               endLctLat: endLctLat,
                                               endLctLng: endLctlng,
                                               strLctLat: starLctLat,
                                               starLctLng: starLctlng )
            // another step-parameters setting
            let tmpTravel = step[keyTravelMode].string
            
            if tmpTravel == TravelMod.driving.rawValue {
                stepDetail.travelMode = .driving
            } else if tmpTravel == TravelMod.transit.rawValue {
                stepDetail.travelMode = .transit
            } else if tmpTravel == TravelMod.walking.rawValue {
                stepDetail.travelMode = .walking
            }
            
            stepDetail.htmlInstructions = step[keyInstructions].string ?? ""
            stepDetail.maneuver = step[keyManeuver].string ?? ""
            
            if step[keySteps].array != nil {
                self.analyteBusModeResponseJSON(stepDetail: &stepDetail, steps:step[keySteps].arrayValue )
                
            } else if step[keyTransitDetails].dictionary != nil {
                self.analyteSubwayModeResponseJSON(stepDetail: &stepDetail, step: step)
            
            } else if step[keyTravelMode].string == "DRIVING" {
                self.analyteDrivingModeResponseJSON(stepDetail: &stepDetail)
                
            } else {
                self.analyteWalkingModeResponseJSON(stepDetail: &stepDetail)
            }
            
            legs.steps.append(stepDetail)
        }
        return legs
    }
    
    
    // Mark: These 3 methods is for handling 4 different travel type response JSONs
    
    private func analyteWalkingModeResponseJSON (stepDetail:inout StepsData) {
        print("走路模式唷")
        stepDetail.trafficType = TrafficType.walking
        stepDetail.travelMode = .walking
    }
    
    private func analyteDrivingModeResponseJSON (stepDetail:inout StepsData) {
        print("駕車模式唷")
        stepDetail.trafficType = TrafficType.driving
        stepDetail.travelMode = .driving
    }
    
    private func analyteBusModeResponseJSON (stepDetail:inout StepsData ,steps:[JSON]) {
        print("近來巴士模式")
        stepDetail.steps = [StepsData]()
        for step in steps {
            let distance = step[keyDistance][keyText].string!
            let duration = step[keyDuration][keyText].string!
            let starLctLat = step[keyStartLocation][keyLat].double!
            let starLctlng = step[keyStartLocation][keyLng].double!
            let endLctLat = step[keyEndLocation][keyLat].double!
            let endLctlng = step[keyEndLocation][keyLng].double!
            
            let stepsData = SecondOrderStepsData()
            stepsData.produceBasicPathObject( distance: distance,
                                              duration: duration,
                                              strAddress: nil,
                                              endAddress: nil,
                                              endLctLat: endLctLat,
                                              endLctLng: endLctlng,
                                              strLctLat: starLctLat,
                                              starLctLng: starLctlng )
            // another step-parameters setting
            let tmpTravel = step[keyTravelMode].string
            
            if tmpTravel == TravelMod.driving.rawValue {
                stepsData.travelMode = .driving
            } else if tmpTravel == TravelMod.transit.rawValue {
                stepsData.travelMode = .transit
            } else if tmpTravel == TravelMod.walking.rawValue {
                stepsData.travelMode = .walking
            }
            
            stepsData.htmlInstructions = step[keyInstructions].string ?? ""
            stepDetail.steps!.append(stepsData)
        }
        stepDetail.travelMode = .bus
        stepDetail.trafficType = .bus
        
        print("\(String(describing: stepDetail.arrivalStop)), \(String(describing: stepDetail.headsign)), \(String(describing: stepDetail.lineAgencies)), \(String(describing: stepDetail.lineShortame))")
    }
    
    private func analyteSubwayModeResponseJSON (stepDetail:inout StepsData ,step:JSON) {
        print("r進來地鐵模式")
        // setting each step's detail
        let transitDetailsData = step[keyTransitDetails]
        
        // setting arrivalStop information
        var tmpStopLct = step[keyTransitDetails][keyArrivalStop][keyLocation].dictionaryValue
        let arrivelStopData = StopInformation()
        arrivelStopData.location = LocationInformation()
        arrivelStopData.name = transitDetailsData[keyArrivalStop][keyName].string ?? ""
        arrivelStopData.location.latitude = tmpStopLct[keyLat]!.doubleValue
        arrivelStopData.location.longitude = tmpStopLct[keyLng]!.doubleValue
        stepDetail.arrivalStop = arrivelStopData
        
        // setting departureStop information
        let departureStopData = StopInformation()
        departureStopData.location = LocationInformation()
        tmpStopLct = (transitDetailsData[keyDepartureStop][keyLocation].dictionaryValue)
        departureStopData.name = transitDetailsData[keyDepartureStop][keyName].string ?? ""
        departureStopData.location.latitude = tmpStopLct[keyLat]!.doubleValue
        departureStopData.location.longitude = tmpStopLct[keyLng]!.doubleValue
        stepDetail.departureStop = departureStopData
        
        // setting time information
        stepDetail.arrivalTime = transitDetailsData[keyArrivalTime][keyText].string
        stepDetail.departureTime = transitDetailsData[keyDepartureTime][keyText].string
        
        stepDetail.headsign = transitDetailsData[keyHeadsign].string
        stepDetail.headway = transitDetailsData[keyHeadway].int
        stepDetail.numbersOfStops = transitDetailsData[keyNumStops].int
        
        // setting line information
        let tmpLineDetail = transitDetailsData[keyLine].dictionaryValue
        let agenciesData = tmpLineDetail[keyAgencies]!.arrayValue
        
        stepDetail.lineAgencies = [String]()
        for agency in agenciesData {
            stepDetail.lineAgencies?.append(agency[keyName].stringValue)
        }
        stepDetail.lineColor = tmpLineDetail[keyColor]?.string ?? "#000000"
        stepDetail.lineShortame = tmpLineDetail[keyShortName]?.string ?? tmpLineDetail[keyName]?.string ?? ""
        stepDetail.lineIcon = "http:" + (tmpLineDetail[keyVehicle]?[keyIcon].string)!
        stepDetail.lineLocalIcon = tmpLineDetail[keyVehicle]?[keyLocalIcon].string ?? ""
        
        stepDetail.trafficType = TrafficType.subwayOrBoat
        print("\(String(describing: stepDetail.arrivalStop)), \(String(describing: stepDetail.headsign)), \(String(describing: stepDetail.lineAgencies)), \(String(describing: stepDetail.lineShortame))")
    }
    
    
    // Mark: It's for testing the trasfer result is correct or not, can't be delete if you're sure this .swift file you are finish.
    private func testPrint(array:[Any?]){
        var i = 0
        for obj in array {
            i += 1
            if obj == nil {
                print("\(i):    ")
            } else {
                print("\(i): \(obj!)")
            }
        }
    }
}

// 撰寫Error情況
class responceError : Error {
    
}



// Mark: The classes for saving JSON datas

class ReponseRoute {
    var fare : Fare?
    var summary : String?
    var legs : LegsData!
}

// 儲存車票票價
class Fare {
    var currency : String!
    var value : Int!
}

// 儲存step＆legs共通的參數
class GeneralDirectionData {
    var distance : String!
    var duration : String!
    var endLocation = LocationInformation()
    var startLocation = LocationInformation()
    
    fileprivate func produceBasicPathObject ( distance:String,
                                              duration:String,
                                              strAddress:String!,
                                              endAddress:String!,
                                              endLctLat:Double,
                                              endLctLng:Double,
                                              strLctLat:Double,
                                              starLctLng:Double ) {
        self.distance = distance
        self.duration = duration
        
        // setting endLocation
        if let adrs = endAddress { self.endLocation.address = adrs }
        self.endLocation.latitude = endLctLat
        self.endLocation.longitude = endLctLng
        
        // setting startLocation
        if let adrs = strAddress { self.endLocation.address = adrs }
        self.startLocation.latitude = strLctLat
        self.startLocation.longitude = starLctLng
    }
}

enum TrafficType : String {
    
    case walking = "walking"
    case subwayOrBoat = "subwayOrBoat"
    case bus = "bus"
    case driving = "driving"
}


// legs
class LegsData: GeneralDirectionData, ResponceRouteType {
    var steps : [StepsData]!
    //大眾運輸模式下參數
    var arrivalTime : TimeInformation!
    var departureTime : TimeInformation!
}

class SecondOrderStepsData: GeneralDirectionData {
    var travelMode : TravelMod!
    var htmlInstructions : String!  //路程簡介
}

// steps
class StepsData: SecondOrderStepsData {
    
    var trafficType : TrafficType!
    
    var maneuver : String?
    var polyline : [String:String]?
    
    var steps : [SecondOrderStepsData]?
    
    //大眾運輸時路程細節
    //    var transitDetail : TransitDetails!
    var arrivalStop : StopInformation?
    var arrivalTime : String?
    var departureStop : StopInformation?
    var departureTime : String?
    var headsign : String?
    var headway : Int?
    var numbersOfStops : Int?
    
    // Line Information
    var lineAgencies : [String]?
    var lineColor : String?
    var lineShortame : String?
    var lineIcon : String?
    var lineLocalIcon : String?
}


class TimeInformation {
    var text : String?
    var timeZone : String?
    var value : Int?
}

class LocationInformation {
    var latitude : Double!
    var longitude : Double!
    var address : String?
}

class StopInformation {
    var location : LocationInformation!
    var name : String?
}


protocol ResponceRouteType { }


