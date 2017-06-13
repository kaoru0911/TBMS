//
//  ObjectTypeTransformer.swift
//  TBMS
//
//  Created by 倪僑德 on 2017/6/13.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces

class DataTypeTransformer {
    
    func transferGMPlaceToSpotDataType(obj: GMSPlace) -> spotData {
        
        let spotObj = spotData()
        spotObj.spotName = obj.name
        spotObj.placeID = obj.placeID
        spotObj.latitude = obj.coordinate.latitude
        spotObj.longitude = obj.coordinate.longitude
        return spotObj
    }
    
    
    func transferSpotDataToAttractionsType(obj: spotData) -> Attraction {
        
        var attr = Attraction()
        attr.attrctionName = obj.spotName
        attr.placeID = obj.placeID
        let coordinate = CLLocationCoordinate2D(latitude: obj.latitude!, longitude: obj.longitude!)
        attr.coordinate = coordinate
        
        return attr
    }
    
    
    func transferAttractionToSpotDataTypeType(obj: Attraction) -> spotData {
        
        let spotObj = spotData()
        spotObj.spotName = obj.attrctionName
        spotObj.placeID = obj.placeID
        spotObj.latitude = obj.coordinate.latitude
        spotObj.longitude = obj.coordinate.longitude
        return spotObj
    }
    
    
    func setValueToAttractionsList(placeList: [GMSPlace]) -> [Attraction] {
        
        var attractionsList = [Attraction]()
        
        for place in placeList {
            var tmpAttraction = Attraction()
            tmpAttraction.setValueToAttractionObject(place: place)
            attractionsList.append(tmpAttraction)
        }
        return attractionsList
    }
    
    
    func setValueToAtrractionListFromSpotList(spotList: [spotData]) -> [Attraction] {
        
        var attractionsList = [Attraction]()
        
        for spot in spotList {
            let attr = transferSpotDataToAttractionsType(obj: spot)
            attractionsList.append(attr)
        }
        return attractionsList
    }
    
    
    func setValueToSpotDataList(attractionList: [Attraction]!) -> [spotData]! {
        
        guard !attractionList.isEmpty else { return nil }
        
        var spotList = [spotData]()
        for i in 0 ... attractionList.count - 1 {
            let spot = transferAttractionToSpotDataTypeType(obj: attractionList[i])
            spotList.append(spot)
        }
        return spotList
    }
}
