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


class CellContent : NSObject {
    var type:CustomerCellType!
}

/// For Storing the cell content about the DateType cell.
class DateCellContent : CellContent {
    var date : Int
    var dateStringForLabel : String
    var colorTypeForScheduleOutoutPage : ColorSetting!
    required init(dateValue:Int) {
        date = dateValue
        dateStringForLabel = "第\(date)天"
    }
}


/// For Storing the cell content about the ScheduleAndTrafficType cell.
class ScheduleAndTrafficCellContent : CellContent {
    var transportationMode : String!
    var trafficTime : String!
    var viewPointName : String!
    var viewPointInformation : String!
    
    required init(nameOfViewPoint:String, transportationMode:String, trafficTime:String) {
        self.viewPointName = nameOfViewPoint
        self.transportationMode = transportationMode
        self.trafficTime = trafficTime
    }
}


/// For checking the cell content's type.
///
/// - dateCellType: Contents for DateType cell.
/// - scheduleAndTrafficCellType: Contents for ScheduleAndTrafficCellContent cell
enum CustomerCellType {
    case dateCellType, scheduleAndTrafficCellType
}


/// For define the color type of the view.
class ColorSetting {
    
}
