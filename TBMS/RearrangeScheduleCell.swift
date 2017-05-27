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
    @IBOutlet weak var viewPointDetail: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var trafficInf: UILabel!
    
}

class DateCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addNewTripDayButton: UIButton!
    @IBAction func addNewTripDay(_ sender: Any) {
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addNewTripDayButton.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    required init(attraction:Attraction, trafficInformation:LegsData!) {
        super.init()
        self.viewPointName = attraction.attrctionName
        self.type = CustomerCellType.scheduleAndTrafficCellType
        
        if trafficInformation != nil {
            self.trafficInformation = trafficInformation
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
}

/// For define the color type of the view.
class ColorSetting {
    
}
