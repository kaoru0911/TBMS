//
//  PocketSpotTVC.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/5.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit


class PocketSpotTVC: UITableViewController {
    
    var selectedCountry: String!
    var selectedProcess: String!
    var sharedData = DataManager.shareDataManager
    var tripFilter: TripFilter!
    var spotList: [spotData]!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tripFilter = TripFilter()
        
        spotList = [spotData]()
        
        spotList = tripFilter.filtBySpotCountry(country: selectedCountry, spotArray: sharedData.pocketSpot!)
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
        
        let image = UIImage(named:"addSpot.png")
        
        cell.spotName.text = spotList[indexPath.row].spotName
        
        switch selectedProcess {
            case "庫存景點":
                cell.addSpotBtn.isHidden = true
            default:
                cell.addSpotBtn.isHidden = false
                cell.addSpotBtn.setBackgroundImage(image, for: .normal)
        }        
        
        return cell
    }
    
    @IBAction func addSpotPress(_ sender: UIButton) {
        
        let a = 0
        
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
