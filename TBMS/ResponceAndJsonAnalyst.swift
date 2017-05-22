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
    
    
    // transfer JSON content to Objct
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
            stepDetail.travelMode = step[keyTravelMode].string
            stepDetail.htmlInstructions = step[keyInstructions].string ?? ""
            stepDetail.maneuver = step[keyManeuver].string ?? ""
            
            if travelMode == "transit" {
                
                if step[keySteps].array != nil {
                    self.analyteBusModeResponseJSON(stepDetail: &stepDetail, steps:step[keySteps].arrayValue )
         
                } else if step[keyTransitDetails].dictionary != nil {
                    self.analyteSubwayModeResponseJSON(stepDetail: &stepDetail, step: step)
                    
                } else {
                    self.analyteWalkingModeResponseJSON()
                }
            }
            legs.steps.append(stepDetail)
        }
        return legs
    }
    
    
    func analyteWalkingModeResponseJSON () {
        print("走路囉")
    }
    
    func analyteBusModeResponseJSON (stepDetail:inout StepsData ,steps:[JSON]) {
        
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
            stepsData.travelMode = step[keyTravelMode].string
            stepsData.htmlInstructions = step[keyInstructions].string ?? ""
            stepDetail.steps.append(stepsData)
        }
    }
    
    func analyteSubwayModeResponseJSON (stepDetail:inout StepsData ,step:JSON) {
        
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
            stepDetail.lineAgencies.append(agency[keyName].stringValue)
        }
        stepDetail.lineColor = tmpLineDetail[keyColor]!.string
        stepDetail.lineShortame = tmpLineDetail[keyShortName]!.string
        stepDetail.lineIcon = tmpLineDetail[keyVehicle]![keyIcon].string ?? ""
        stepDetail.lineLocalIcon = tmpLineDetail[keyVehicle]![keyLocalIcon].string ?? ""
    }
    
    //    // 測試用func : 測試物件屬性的值有被正確帶入
    //    private func testPrint(array:[Any?]){
    //        var i = 0
    //        for obj in array {
    //            i += 1
    //            if obj == nil {
    //                print("\(i):    ")
    //            } else {
    //                print("\(i): \(obj!)")
    //            }
    //        }
    //    }
    
}

// 撰寫Error情況
class responceError : Error {
    
}




// 物件結構
class ReponseRoute {
    var fare : Fare!
    var summary : String!
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

// legs
class LegsData: GeneralDirectionData {
    var steps : [StepsData]!
    //大眾運輸模式下參數
    var arrivalTime : TimeInformation!
    var departureTime : TimeInformation!
}

class SecondOrderStepsData: GeneralDirectionData {
    var travelMode : String!
    var htmlInstructions : String!  //路程簡介
}

// steps
class StepsData: SecondOrderStepsData {
    
    var maneuver : String!
    var polyline : [String:String]!
    
    var steps : [SecondOrderStepsData]!
    
    //大眾運輸時路程細節
    //    var transitDetail : TransitDetails!
    var arrivalStop : StopInformation!
    var arrivalTime : String!
    var departureStop : StopInformation!
    var departureTime : String!
    var headsign : String!
    var headway : Int!
    var numbersOfStops : Int!
    
    // Line Information
    var lineAgencies : [String]!
    var lineColor : String!
    var lineShortame : String!
    var lineIcon = "" {
        willSet{ self.lineIcon = "http:" + newValue }
    }
    var lineLocalIcon = "" {
        willSet{ self.lineLocalIcon = "http:" + newValue }
    }
    
}

class TimeInformation {
    var text : String!
    var timeZone : String!
    var value : Int!
}

class LocationInformation {
    var latitude : Double!
    var longitude : Double!
    var address : String!
}

class StopInformation {
    var location : LocationInformation!
    var name : String!
}





