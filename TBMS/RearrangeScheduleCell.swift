//
//  ScheduleAndTrafficCell.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/26.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit

class ScheduleAndTrafficCell: UICollectionViewCell {
    
    @IBOutlet weak var viewPointBGBlock: UIImageView!
    @IBOutlet weak var viewPointName: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var trafficInf: UILabel!
    
}

class LastAttractionCell: UICollectionViewCell {
    
    @IBOutlet weak var viewPointBGBlock: UIImageView!
    @IBOutlet weak var viewPointName: UILabel!
}

class DateCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addNewTripDayButton: UIButton!
    @IBAction func addNewTripDay(_ sender: Any) {
    }
}



//class CellContent : NSObject {
//    var type:CustomerCellType!
//}

class CellContent : NSObject {
    var type:CustomerCellType!
}

/// For Storing the cell content about the DateType cell.
class DateCellContent : CellContent {
    var date : Int!
    var dateStringForLabel : String!
    var colorTypeForScheduleOutoutPage : ColorSetting!
    
    required init(dateValue:Int) {
        super.init()
        self.date = dateValue
        self.dateStringForLabel = "第\(dateValue)天"
        self.type = CustomerCellType.dateCellType
    }
}

/// For Storing the cell content about the ScheduleAndTrafficType cell.
class ScheduleAndTrafficCellContent : CellContent {
    var travelMode : String!
    var trafficTime : String!
    var viewPointName : String!
    var attraction : Attraction!
    var trafficInformation : LegsData!
    
    private let strTransitTravelMode = "TRANSIT"
    private let strWalkingTravelMode = "WALKING"
    private let strDrivingTravelMode = "DRIVING"
    
    private let strDisplayTransitMode = TravelMod.transit.rawValue
    private let strDisplayDrivingMode = TravelMod.driving.rawValue
    private let strDisplayWalkingMode = TravelMod.walking.rawValue
    
    required init(attraction:Attraction, trafficInformation:LegsData!) {
        super.init()
        self.viewPointName = attraction.attrctionName
        self.attraction = attraction
        self.type = CustomerCellType.scheduleAndTrafficCellType
        
        self.setTrafficValue(legsData: trafficInformation)
    }
    
    func setTrafficValue(legsData:LegsData!) {
        
        guard let trafficInformation = legsData else {
            print("沒有資料唷")
            self.trafficInformation = nil
            self.trafficTime = "routeCalculate error"
            return
        }
        self.trafficInformation = trafficInformation
        self.trafficTime = self.trafficInformation.duration
        
            self.travelMode = strDisplayWalkingMode
            var i = 0
            
            for step in self.trafficInformation.steps {
                guard step != nil else{
                    print("這是走路模式, 沒有step唷")
                    return
                }
                
                if step.travelMode == strTransitTravelMode {
                    self.travelMode = strDisplayTransitMode
                    
                    break
                    
                } else if step.travelMode == strDrivingTravelMode {
                    self.travelMode = strDisplayDrivingMode
                    break
                }
            }
    }
}

/// For checking the cell content's type.
///
/// - dateCellType: Contents for DateType cell.
/// - scheduleAndTrafficCellType: Contents for ScheduleAndTrafficCellContent cell
enum CustomerCellType : String{
    case dateCellType = "dateCell"
    case scheduleAndTrafficCellType = "scheduleAndTrafficCell"
    case lastAttactionCellType = "lastAttactionCellType"
}

/// For define the color type of the view.
class ColorSetting {
    
}
