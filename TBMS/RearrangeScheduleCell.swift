//
//  ScheduleAndTrafficCell.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/26.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit

class CustomerCell: UICollectionViewCell {
    
    
    func handleswipeLeftGesture( gesture: UISwipeGestureRecognizer) {
        
        guard gesture.direction == .left else { return }
        
//        guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else { return }
        
//        guard let cell = self.collectionView.cellForItem(at: selectedIndexPath) as? DateCell else {
            return
    }
    
        //        cell.isFocused = true
        //        let frame = cell.addNewTripDayButton.frame
        //
        //        let deleteButton = UIButton(frame: frame)
        //        deleteButton.titleLabel?.text = "刪除"
        //        deleteButton.isHidden = false
        //        deleteButton.addTarget(self, action: #selector(self.deleteCell), for: UIControlEvents.touchUpInside)
        //        cell.reloadInputViews()
        //
        //        self.collectionView.reloadItems(at: [selectedIndexPath])
    
    
    func deleteCell(index: IndexPath) {
        
    }
}

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
    
    @IBOutlet weak var cellContentBlock: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addNewTripDayButton: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBAction func addNewTripDay(_ sender: Any) {}
}

class CellContent: NSObject {
    var type: CustomerCellType!
    var cellColor: UIColor!
}

/// For Storing the cell content about the DateType cell.
class DateCellContent: CellContent {
    
    var date: Int!
    var dateStringForLabel: String! {
        get { return "第\(date!)天" }
    }
    var colorTypeForScheduleOutoutPage: ColorSetting!
    
    required init(dateValue:Int) {
        super.init()
        self.date = dateValue
//        self.dateStringForLabel = "第\(dateValue)天"
        self.type = CustomerCellType.dateCellType
    }
}

/// For Storing the cell content about the ScheduleAndTrafficType cell.
class ScheduleAndTrafficCellContent: CellContent {
    
    var travelMode: TravelMod!
    var trafficTime: String!
    var viewPointName: String!
    var attraction: Attraction!
    var trafficInformation: LegsData!
    var placeID: String!
    var address: String!
    
    //    private let strTransitTravelMode: TravelMod = .transit
    //    private let strWalkingTravelMode: TravelMod = .walking
    //    private let strDrivingTravelMode: TravelMod = .driving
    
    let calculateErrorWarnning: String! = "routeCalculate error"
    
    private let strDisplayTransitMode = "公車/捷運"
    private let strDisplayDrivingMode = "開車"
    private let strDisplayWalkingMode = "走路"
    
    required init(attraction:Attraction, trafficInformation:LegsData!, selectedTravelMode: TravelMod) {
        
        super.init()
        self.viewPointName = attraction.attrctionName
        self.attraction = attraction
        self.type = CustomerCellType.scheduleAndTrafficCellType
        self.setTrafficValue(legsData: trafficInformation)
        self.placeID = attraction.placeID
        self.address = attraction.address
        
        guard selectedTravelMode != .transit else { return }
        self.travelMode = selectedTravelMode
    }
    
    func setTrafficValue(legsData:LegsData!) {
        
        guard let trafficInformation = legsData else {
            print("trafficInformation沒有資料唷")
            self.trafficInformation = nil
            self.trafficTime = calculateErrorWarnning
            return
        }
        
        self.trafficInformation = trafficInformation
        self.trafficTime = self.trafficInformation.duration
        self.travelMode = .walking
        
        guard let routeDetail = self.trafficInformation.steps else{
            print("這是走路模式, 沒有step唷")
            return
        }
        
        for step in routeDetail {
            
            if step.travelMode == .transit {
                self.travelMode = .transit
                
            } else if step.travelMode == .driving {
                self.travelMode = .driving
            }
        }
    }
}

/// For checking the cell content's type.
///
/// - dateCellType: Contents for DateType cell.
/// - scheduleAndTrafficCellType: Contents for ScheduleAndTrafficCellContent cell
enum CustomerCellType: String{
    case dateCellType = "dateCell"
    case scheduleAndTrafficCellType = "scheduleAndTrafficCell"
    case lastAttactionCellType = "lastAttactionCellType"
}

/// For define the color type of the view.
class ColorSetting {
    
}
