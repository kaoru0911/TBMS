//
//  BestPathCalculator.swift
//  ModelTest2
//
//  Created by 倪僑德 on 2017/5/19.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

/// A generator has func can rearrange the attractions order by traffic time to get the best Route.
class BestRouteCalculator: NSObject {
    
    private var firstStartingPoint : PlaceObject
    private var totalAttractions : [PlaceObject]
    private var totalAttractionsSum : Int
    
    /// Attractions order list, we could use it after getBestRoute method finished.
    /// If you want to use it, please call it in the closure "completion" of getBestRoute method.
    var bestRoute = [PlaceObject]()
    private let request = MKDirectionsRequest()
    
    /// initializer
    ///
    /// - Parameters:
    ///   - startingPoint: The first attraction.
    ///   - attractionsList: All the attraction you want to visit.
    init(startingPoint:PlaceObject, attractionsList:[PlaceObject]) {
        self.firstStartingPoint = startingPoint
        self.totalAttractions = attractionsList
        self.totalAttractionsSum = attractionsList.count
    }
    
    /// Rearrange the attractions visited order by traffic time to get the best Route.
    ///
    /// - Parameter completion: What you want to do after the calculation is finished.
    func getBestRoute(completion:@escaping () -> Void){

        let backgroundQueue = DispatchQueue(label: "bgQ")
        backgroundQueue.async {
            self.rearrangeRoute(startingPlace: self.firstStartingPoint, attractionsList: self.totalAttractions, queue: backgroundQueue, completion: completion)
        }
    }
    
    /// Rearrange the attraction order to find the best Route.
    ///
    /// - Parameters:
    ///   - startingPlace: The first attraction.
    ///   - attractionsList: All the attraction you want to visit.
    ///   - queue: If we want to run this function in background queue.
    ///   - completion: What you want to do after the calculation is finished.
    private func rearrangeRoute(startingPlace:PlaceObject, attractionsList:[PlaceObject], queue:DispatchQueue ,completion:@escaping () -> Void){
        
        var finishCalCount = attractionsList.count
        var finishTravelTimeCalculateAttrs = [PlaceObject]()
        
        // setting the request detail about getting travelTime
        self.request.transportType = .automobile
        self.request.source = MKMapItem(placemark:(MKPlacemark(coordinate: startingPlace.location)))
        
        // find the closest attraction
        for i in 0...attractionsList.count-1 {
            let arrivalPlace = attractionsList[i]
            
            // sending request
            self.request.destination = MKMapItem(placemark:(MKPlacemark(coordinate: arrivalPlace.location)))
            let directCalculator = MKDirections(request: self.request)
    
            directCalculator.calculateETA(completionHandler: { (response, error) in
                if error == nil {
                    if let r = response {
                        
                        arrivalPlace.trafficTime = r.expectedTravelTime
                        finishTravelTimeCalculateAttrs += [arrivalPlace]
                        finishCalCount -= 1
                        
                        // When we get all of the response, compare the trafficTime from each attraction to the starting place.
                        if finishCalCount == 0 {
                            
                            let (nextStartingPlace,unarrangedArray) = findClosestAttractions(attractionsArray: finishTravelTimeCalculateAttrs)
                            finishCalCount = unarrangedArray.count
                            self.bestRoute += [nextStartingPlace]
                            
                            // If we still have unarrangeAttractions, run this func again.
                            if self.bestRoute.count < self.totalAttractionsSum {
                                queue.async {
                                self.rearrangeRoute(startingPlace: nextStartingPlace, attractionsList: unarrangedArray, queue: queue, completion: completion)
                                }
                            // If all of the attractions are rearrange, run the completion closure.
                            } else {
                                self.bestRoute.insert(self.firstStartingPoint, at: 0)
                                completion()
                            }
                        }
                    }
                } else {
                    print("Error=\(error ?? "" as! Error)")
                }
            })
        }
    }
}

/// To find the object has shortest traffic time
///
/// - Parameter attractionsArray: The object list we want to compare
/// - Returns: The one with shortest traffic time
private func findClosestAttractions (
    attractionsArray:[PlaceObject]) -> (nextAttractions:PlaceObject, remainingAttractionsArray:[PlaceObject])!{

    let nextAttractions = attractionsArray.min { $0.0.trafficTime < $0.1.trafficTime }
    let remainArray = attractionsArray.filter({$0 != nextAttractions})
    //    remainArray.map({$0.trafficTime = nil})
    return (nextAttractions,remainArray) as! (nextAttractions: PlaceObject, remainingAttractionsArray: [PlaceObject])
}

class PlaceObject : NSObject{
    var name : String!
    var location:CLLocationCoordinate2D!
    var trafficTime : Double!
}


