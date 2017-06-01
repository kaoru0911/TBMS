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
    
    var data = DataManager.shareDataManager
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        for _ in 0..<(data.pocketTrips?[0].spots.count)! {
            
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
        return (data.pocketTrips?[0].spots.count)!//spotArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCellID", for: indexPath) as! ScheduleTableViewCell
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)

        cell.spotItemLabel.text = data.pocketTrips?[0].spots[indexPath.row].spotName  //spotArray[indexPath.row]

        cell.spotItemLabel.backgroundColor = UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1)
        
        cell.spotItemLabel.layer.cornerRadius = 10
        cell.spotItemLabel.layer.masksToBounds = true

        // auto line break
        cell.describeLabel.text = data.pocketTrips?[0].spots[indexPath.row].trafficToNextSpot

        // 自動調整高度
        cell.describeLabel.numberOfLines = 0
        cell.describeLabel.sizeToFit()
        cell.describeLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        
        // 判斷預設cell高度是否放得下敘述
        let labelHeight = defaultCellHeight - cell.spotItemLabel.frame.height
        
        if cell.describeLabel.frame.height > labelHeight{
            
            if selectCellRow[indexPath.row] {
                cell.describeLabel.text = data.pocketTrips?[0].spots[indexPath.row].trafficToNextSpot
            } else{
                cell.describeLabel.text = "檢視詳細交通資訊"
            }
            
            cellHeightArray.append(cell.describeLabel.frame.height + cell.spotItemLabel.frame.height + 10)
            
        } else{
            cellHeightArray.append(defaultCellHeight)
        }
        
        if cell.describeLabel.text == "" {
            
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

}
