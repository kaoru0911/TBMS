//
//  PocketSpotTVC.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/5.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit
import GooglePlaces


class PocketSpotTVC: UITableViewController {
    
    
    var selectedCountry: String!
    var selectedProcess: String!
    var sharedData = DataManager.shareDataManager
    let server = ServerConnector()
    var tripFilter: TripFilter!
    var spotList: [spotData]!
    
    var selectedSpots = [spotData]()
    var selectedIndex = [Int]()
    var scheduleAttractions = [Attraction]()
    let typeTransformer = DataTypeTransformer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tripFilter = TripFilter()
        
        let inputSpotList = tripFilter.filtBySpotCountry(country: selectedCountry, spotArray: sharedData.pocketSpot!)
        let existSpots = typeTransformer.setValueToSpotDataList(attractionList: scheduleAttractions)
        
        spotList = existSpotsFilter(totalSpotDatas: inputSpotList, existSpotDatas: existSpots)
        //        let spot = spotData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return spotList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotCell", for: indexPath) as! PocketSpotTVCell
        
        cell.spotName.text = spotList[indexPath.row].spotName
        cell.selectStatus.isHidden = true
        cell.addSpotBtn.tag = indexPath.row
        
        if selectedProcess == "庫存景點" {
            
            cell.addSpotBtn.isHidden = false
            let image = UIImage(named:"deleteSpot.png")
            cell.addSpotBtn.setBackgroundImage(image, for: .normal)
            
        } else if selectedIndex.contains(indexPath.row) == false {
            
            cell.addSpotBtn.isHidden = false
            let image = UIImage(named:"addSpot.png")
            cell.addSpotBtn.setBackgroundImage(image, for: .normal)
        }
        
        if selectedIndex.contains(indexPath.row) {
            cell.selectStatus.isHidden = false
        }
        
        return cell
    }
    
    @IBAction func addSpotPress(_ sender: UIButton) {
        
        let index = sender.tag
        
        if selectedProcess != "庫存景點" {
            
            selectedSpots.append(spotList[index])
            selectedIndex.append(index)
            sender.isHidden = true
            
        } else {
            
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! PocketSpotTVCell
            
            print("cellSpotName = \(cell.spotName.text!)")
            guard let spotName = cell.spotName.text else {
                print("SpotName doesn't exist")
                return
            }
            
            sharedData.pocketSpot?.remove(at: index)
            spotList.remove(at: index)
            server.deletePocketSpotFromServer(spotName: spotName)
        }
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //畫面精進，讓點選後的灰色不會卡在選擇列上，灰色會閃一下就消失
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func prepareSpotList(pocketSpot:[spotData]) -> [spotData] {
        
        let spotList: [spotData]
        
        spotList = tripFilter.filtBySpotCountry(country: selectedCountry, spotArray: pocketSpot)
        
        return spotList
    }
}

extension PocketSpotTVC {
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let selectedAttractions = typeTransformer.setValueToAtrractionListFromSpotList(spotList: selectedSpots)
        
        NotificationCenter.default.post( name: NSNotification.Name(rawValue: "PocketSpotTVCDisappear"),
                                         object: selectedAttractions )
    }
    
    
    func existSpotsFilter(totalSpotDatas: [spotData], existSpotDatas: [spotData]!) -> [spotData] {
        
        guard existSpotDatas != nil else { return totalSpotDatas }
        
        var tmpSpotsArray = totalSpotDatas
        for spot in totalSpotDatas {
            if existSpotDatas.contains(spot) {
                let index = tmpSpotsArray.index(of: spot)
                tmpSpotsArray.remove(at: index!)
            }
        }
        return tmpSpotsArray
    }
}
