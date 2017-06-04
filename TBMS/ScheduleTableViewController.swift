//
//  ScheduleTableViewController.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/25.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController {
    
    let defaultCellHeight:CGFloat = 60
    var selectCellRow:Array<Bool> = []
    var cellHeightArray:Array<CGFloat> = []
    
    var data = tripData()
    var spotData = [tripSpotData]()
    var addAttrIndexList = [Int]()
    
    var filter = TripFilter()
    var nDaySchedule: Int!
    
    //====test===
    //    var sharedData = DataManager.shareDataManager
    //=======
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        //        data = (sharedData.pocketTrips?[0])!
        
        //        nDaySchedule = 2
        
        spotData = filter.filtBySpotNDays(nDays: nDaySchedule, trip: data)
        
        checkSpotPosition(spotArray: &spotData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        for _ in 0..<data.spots.count {
            
            selectCellRow.append(false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return spotData.count//spotArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCellID", for: indexPath) as! ScheduleTableViewCell
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        cell.spotItemLabel.text = spotData[indexPath.row].spotName  //spotArray[indexPath.row]
        
        cell.spotItemLabel.backgroundColor = UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1)
        
        cell.spotItemLabel.layer.cornerRadius = 10
        cell.spotItemLabel.layer.masksToBounds = true
        
        // auto line break
        cell.describeLabel.text = spotData[indexPath.row].trafficToNextSpot
        
        // 自動調整高度
        cell.describeLabel.numberOfLines = 0
        cell.describeLabel.sizeToFit()
        cell.describeLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        
        // 判斷預設cell高度是否放得下敘述
        let labelHeight = defaultCellHeight - cell.spotItemLabel.frame.height
        
        if cell.describeLabel.frame.height > labelHeight{
            
            if selectCellRow[indexPath.row] {
                cell.describeLabel.text = spotData[indexPath.row].trafficToNextSpot
            } else{
                cell.describeLabel.text = spotData[indexPath.row].trafficTitle
            }
            
            cellHeightArray.append(cell.describeLabel.frame.height + cell.spotItemLabel.frame.height + 10)
            
        } else{
            cellHeightArray.append(defaultCellHeight)
        }
        
        if cell.describeLabel.text == "" || cell.describeLabel.text == nil || indexPath.row == spotData.count - 1 {
            
            cell.describeLabel.text = ""
            
        } else{
            // 放入箭頭圖片
            cell.cellImage.image = UIImage(named: "downArrow2")
        }
        
        return cell
    }
    
    //    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //
    //        return 80
    //    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellRowHeight:CGFloat
        
        if selectCellRow[indexPath.row]{
            cellRowHeight = cellHeightArray[indexPath.row]
        } else{
            cellRowHeight = 60
        }
        
        return cellRowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCellRow[indexPath.row] = !selectCellRow[indexPath.row]
        
        tableView.reloadData()
    }
    
    func checkSpotPosition( spotArray:inout Array<tripSpotData>) {
        
        var tmp = tripSpotData()
        
        // bubble sortting
        for i in 0...spotArray.count - 1 {
            
            for j in i...spotArray.count - 1 {
                
                if spotArray[i].nTh > spotArray[j].nTh {
                    
                    tmp = spotArray[j]
                    
                    spotArray[j] = spotArray[i]
                    
                    spotArray[i] = tmp
                }
            }
        }
    }
    
}
