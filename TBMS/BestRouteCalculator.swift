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
    
    private var firstStartingPoint : Attraction
    private var totalAttractions : [Attraction]
    private var totalAttractionsSum : Int
    private let request = MKDirectionsRequest()
    
    /// Attractions order list, we could use it after getBestRoute method finished.
    /// If you want to use it, please call it in the closure "completion" of getBestRoute method.
    var bestRoute = [Attraction]()
    
    /// initializer
    ///
    /// - Parameters:
    ///   - startingPoint: The first attraction.
    ///   - attractionsList: All the attraction you want to visit.
    init(startingPoint:Attraction, attractionsList:[Attraction]) {
        self.firstStartingPoint = startingPoint
        self.totalAttractions = attractionsList
        self.totalAttractionsSum = attractionsList.count
    }
    
    /// Rearrange the attractions visited order by traffic time to get the best Route.
    ///
    /// - Parameter completion: What you want to do after the calculation is finished.
    func getBestRoute(completion:@escaping (_ bestRoute:[Attraction]) -> Void){
        
        let backgroundQueue = DispatchQueue(label: "bgQ")
        backgroundQueue.async {
            self.rearrangeRoute(startingPlace: self.firstStartingPoint,
                                attractionsList: self.totalAttractions,
                                queue: backgroundQueue,
                                completion: completion)
        }
    }
    
    /// Rearrange the attraction order by coordinate to find the best Route.
    ///
    /// - Parameters:
    ///   - startingPlace: The first attraction.
    ///   - attractionsList: All the attraction you want to visit.
    ///   - queue: If we want to run this function in background queue.
    ///   - completion: What you want to do after the calculation is finished.
    private func rearrangeRoute(startingPlace:Attraction,
                                attractionsList:[Attraction],
                                queue:DispatchQueue ,
                                completion:@escaping (_ bestRoute:[Attraction]) -> Void){
        
        var finishCalCount = attractionsList.count
        var finishTravelTimeCalculateAttrs = [Attraction]()
        
        let sourceCoordinate = CLLocation( latitude: startingPlace.coordinate.latitude,
                                           longitude: startingPlace.coordinate.longitude )
        // find the closest attraction
        for i in 0...attractionsList.count-1 {
            
            var arrivalPlace = attractionsList[i]
            
            let destinationCoordinate = CLLocation( latitude: arrivalPlace.coordinate.latitude,
                                                    longitude: arrivalPlace.coordinate.longitude )
            
            let distance = destinationCoordinate.distance(from: sourceCoordinate)
            
            arrivalPlace.trafficTime = distance
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
                    completion(self.bestRoute)
                }
            }
        }
        
    }
    
    //    /// Rearrange the attraction order by traffic time to find the best Route.  (以交通時間做計算)
    //    ///
    //    /// - Parameters:
    //    ///   - startingPlace: The first attraction.
    //    ///   - attractionsList: All the attraction you want to visit.
    //    ///   - queue: If we want to run this function in background queue.
    //    ///   - completion: What you want to do after the calculation is finished.
    //    private func rearrangeRoute2(startingPlace:Attraction, attractionsList:[Attraction], queue:DispatchQueue ,completion:@escaping (_ bestRoute:[Attraction]) -> Void){
    //
    //        var finishCalCount = attractionsList.count
    //        var finishTravelTimeCalculateAttrs = [Attraction]()
    //
    //        // setting the request detail about getting travelTime
    //        self.request.transportType = .walking
    //
    //        if #available(iOS 10.0, *) {
    //            self.request.source = MKMapItem(placemark:(MKPlacemark(coordinate: startingPlace.coordinate)))
    //        } else {
    //            // Fallback on earlier versions
    //        }
    //
    //        // find the closest attraction
    //        for i in 0...attractionsList.count-1 {
    //            var arrivalPlace = attractionsList[i]
    //
    //            // sending request
    //            if #available(iOS 10.0, *) {
    //                self.request.destination = MKMapItem(placemark:(MKPlacemark(coordinate: arrivalPlace.coordinate)))
    //            } else {
    //                // Fallback on earlier versions
    //            }
    //
    //            let directCalculator = MKDirections(request: self.request)
    //
    //            directCalculator.calculateETA(completionHandler: { (response, error) in
    //                if error == nil {
    //                    if let r = response {
    //
    //                        arrivalPlace.trafficTime = r.expectedTravelTime
    //                        finishTravelTimeCalculateAttrs += [arrivalPlace]
    //                        finishCalCount -= 1
    //
    //                        // When we get all of the response, compare the trafficTime from each attraction to the starting place.
    //                        if finishCalCount == 0 {
    //
    //                            let (nextStartingPlace,unarrangedArray) = findClosestAttractions(attractionsArray: finishTravelTimeCalculateAttrs)
    //                            finishCalCount = unarrangedArray.count
    //                            self.bestRoute += [nextStartingPlace]
    //
    //                            // If we still have unarrangeAttractions, run this func again.
    //                            if self.bestRoute.count < self.totalAttractionsSum {
    //                                queue.async {
    //                                    self.rearrangeRoute(startingPlace: nextStartingPlace, attractionsList: unarrangedArray, queue: queue, completion: completion)
    //                                }
    //                                // If all of the attractions are rearrange, run the completion closure.
    //                            } else {
    //                                self.bestRoute.insert(self.firstStartingPoint, at: 0)
    //                                completion(self.bestRoute)
    //                            }
    //                        }
    //                    }
    //                } else {
    //                    print("Error=\(error ?? "" as! Error)")
    //                }
    //            })
    //        }
    //    }
    
    /// To find the object has shortest traffic time
    ///
    /// - Parameter attractionsArray: The object list we want to compare
    /// - Returns: The one with shortest traffic time
    private func findClosestAttractions (attractionsArray:[Attraction]) -> (nextAttractions:Attraction, remainingAttractionsArray:[Attraction])!{
        
        let nextAttractions = attractionsArray.min { $0.0.trafficTime < $0.1.trafficTime }!
        let remainArray = attractionsArray.filter({$0.placeID != nextAttractions.placeID})
        //        remainArray.map({$0.trafficTime = nil})
        return (nextAttractions,remainArray)
    }
}



