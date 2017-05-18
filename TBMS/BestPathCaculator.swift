//
//  BestPathCaculator.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/19.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import Foundation
import MapKit

class BestPathCaculator : NSObject {
    let mapDirection = MKDirections()
    
    //計算合理路線
    //匯入值增改為座標, 如果回傳
    func pathCaculator (startingPoit:[String:Any], viewPointArray:[[String:Any]])-> [[String:Any]]!{
        // 傳入座標, 先計算第一個點與所有點的交通時間
        // 每次都保留最接近路線
        
        //宣告第一點, 景點Array, 最佳行程Array
        var lastViewPoint = startingPoit
        var remainingArray = viewPointArray
        var bestPathViewPointArray = [startingPoit]
        
        //將原本行程重新排列成最佳路線
        for _ in 0 ... viewPointArray.count-1 {
            // 算完第一次, 取得第二點與剩餘Array
            (lastViewPoint, remainingArray) = findTheNextViewPoint(startingPoint: lastViewPoint, viewPointArray: remainingArray)
            
            // 將第二點加到最佳行程Array List
            bestPathViewPointArray.append(lastViewPoint)
        }
        return bestPathViewPointArray
    }
    
    //讀入起始點＆array, 傳出第二點＆剩餘Array
    func findTheNextViewPoint (startingPoint:[String:Any], viewPointArray:[[String:Any]]) -> (nextViewPoint:[String:Any], remainingViewPointArray:[[String:Any]])!{
        
        //設定起點
        let sourceCoordinate = startingPoint["viewPointCoordinate"] as? CLLocationCoordinate2D
        //設定計算下一景點暫存用
        var theNextViewPoint : [String:Any]!
        var trafficTimeCompare : Int!
        var indexOftheNextViewPoint = 0
        
        var i = 0
        //依序將景點導入計算最佳路線
        for tmpViewPoint in viewPointArray {
            let destinationCoordinate = tmpViewPoint["viewPointCoordinate"] as? CLLocationCoordinate2D
            
            //確認轉換有成功
            guard let source = sourceCoordinate else {
                print("sourceCoordinate doesn't exist")
                return nil
            }
            guard let destination = destinationCoordinate else {
                print("destinationCoordinate doesn't exist")
                return nil
            }
            //計算時間
            let trafficInformation = trafficTimeCaculator(startingPoint: source, destinationPoint: destination)
            
            //確認是否是迴圈第一圈
            if trafficTimeCompare == nil {
                trafficTimeCompare = trafficInformation.trafficTime
                theNextViewPoint = tmpViewPoint
            }
            
            //如果時間較短則取代本次景點為最佳下一景點
            if trafficInformation.trafficTime < trafficTimeCompare {
                theNextViewPoint = tmpViewPoint
                indexOftheNextViewPoint = i
            }
            i += 1
        }
        //將最佳第二點從剩餘Array中踢出
        var tmpArray = viewPointArray
        tmpArray.remove(at: indexOftheNextViewPoint)
        let remainingViewPointArray = tmpArray
        return (theNextViewPoint,remainingViewPointArray)

    }
    
    //計算兩點間之距離
    func trafficTimeCaculator (startingPoint:CLLocationCoordinate2D, destinationPoint:CLLocationCoordinate2D) -> (distance:String,trafficTime:Int) {
        
        //設定交通方式
        let request = MKDirectionsRequest()
        request.transportType = .automobile
        
        //設定起始點＆終點
        request.source = MKMapItem(placemark:(MKPlacemark(coordinate: startingPoint)))
        request.destination = MKMapItem(placemark:(MKPlacemark(coordinate: destinationPoint)))
        
        //設定要讀取資料
        var distance : String!
        var trafficTime : Int!
        
        let calcuteDirections = MKDirections(request: request)
        calcuteDirections.calculateETA{ response, error in
            if error == nil {
                if let r = response {
                    distance = NSString(format: "%.2f公里",r.distance/1000) as String
                    trafficTime = Int(r.expectedTravelTime)
                }
            }
        }
        return (distance,trafficTime)
        
    }
    
}
