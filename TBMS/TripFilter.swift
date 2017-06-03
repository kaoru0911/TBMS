//
//  TripFilter.swift
//  TBMS
//
//  Created by popcool on 2017/5/31.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit

class TripFilter: NSObject {
    
    func filtByTripDays(days:Int, tripArray:Array<tripData>) -> Array<tripData> {
        
        var resultArray = [tripData]()
        
        resultArray = tripArray.filter { (tripData) -> Bool in
            tripData.days == days
        }
        
        return resultArray
    }
    
    func filtByTripCountry(country:String, tripArray:Array<tripData>) -> Array<tripData> {
        
        var resultArray = [tripData]()        
        
        resultArray = tripArray.filter { (tripData) -> Bool in
            tripData.country == country
        }
        
        return resultArray
    }
    
    func filtBySpotCountry(country:String, spotArray:Array<spotData>) -> Array<spotData> {
        
        var resultArray = [spotData]()
        
        resultArray = spotArray.filter { (spotData) -> Bool in
            spotData.spotCountry == country
        }
        
        return resultArray
    }
    
    func filtBySpotNDays(nDays:Int, trip:tripData) -> Array<tripSpotData> {
        
        var resultArray = [tripSpotData]()
        
        resultArray = trip.spots.filter { (tripSpotData) -> Bool in
            tripSpotData.nDays == nDays
        }
        
        return resultArray
    }

}
