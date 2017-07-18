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
    let generalModel = GeneralToolModels()
    let googlePlaceCaller = GooglePlaceCaller()
    var tripFilter: TripFilter!
    var spotList: [spotData]!
    
    var selectedSpots = [spotData]()
    var selectedIndex = [Int]()
    var scheduleAttractions = [Attraction]()
    let typeTransformer = DataTypeTransformer()
    
    var spotImages = [CustormerImage]()
    
    let imageDownloadNotidicationName = "imgDownload"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
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
        
        let spot = spotList[indexPath.row]
        
        cell.spotName.text = spot.spotName
        cell.spotName.lineBreakMode = .byTruncatingTail
        cell.selectStatus.isHidden = true
        cell.addSpotBtn.tag = indexPath.row
        
        let image = spotImages[indexPath.row]
//        image.index = indexPath.row
        cell.spotImage.image = image.image
        
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
        
        if image.imageType == .loadingImg {
            
            guard let placeID = spot.placeID else {
                print("ERROR: \(cell.spotName)'s placeID doesn't exist")
                return cell
            }
            
            let name = googlePlaceCaller.nameAndIndexEncodeToNotificationName(name: self.imageDownloadNotidicationName,
                                                                         index: image.index ?? 0)
            let notificationName = Notification.Name(rawValue: name)
            
            NotificationCenter.default.addObserver(self, selector: #selector(imgDownLoadSuccessNotificationDidGet), name: notificationName, object: nil)
            
            googlePlaceCaller.loadFirstPhotoForPlace(placeID: placeID, notificationName: name)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PocketSpotTVC {
    
    override func viewWillAppear(_ animated: Bool) {
        
        tripFilter = TripFilter()
        
        let inputSpotList = tripFilter.filtBySpotCountry(country: selectedCountry, spotArray: sharedData.pocketSpot!)
        let existSpots = typeTransformer.setValueToSpotDataList(attractionList: scheduleAttractions)
        spotList = existSpotsFilter(totalSpotDatas: inputSpotList, existSpotDatas: existSpots)
        
        guard spotList.isEmpty == false else {
            return
        }
        
        for _ in 0 ... spotList.count - 1 {
            
            let image = CustormerImage()
            spotImages.append(image)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        
        let selectedAttractions = typeTransformer.setValueToAtrractionListFromSpotList(spotList: selectedSpots)
        
        NotificationCenter.default.post( name: NSNotification.Name(rawValue: NotificationName.pocketSpotTVCDisappear.rawValue),
                                         object: selectedAttractions )
    }
    
    
    func existSpotsFilter(totalSpotDatas: [spotData], existSpotDatas: [spotData]?) -> [spotData]? {
        
        guard totalSpotDatas.isEmpty == false else {
            
            print("WARNING: totalSpotDatas is empty.")
            return totalSpotDatas
        }
        
        guard let existSpotDatas = existSpotDatas else {
            
            print("ERROR: existSpotDatas is nil!")
            return totalSpotDatas
        }
        
        guard existSpotDatas.isEmpty == false else {
            
            print("WARNING: existSpotDatas is empty.")
            return totalSpotDatas
        }
        
        var tmpSpotsArray = totalSpotDatas
        
        for existSpot in existSpotDatas {
            
            tmpSpotsArray = tmpSpotsArray.filter { $0.placeID != existSpot.placeID }
        }
        
        return tmpSpotsArray
    }
    
    func imgDownLoadSuccessNotificationDidGet(notification: Notification) {
        
        guard let image = notification.object as? CustormerImage else {
            print("ERROR: Objct pass by notification is not a CustormerImage objct.")
            return
        }
        
        guard let index = image.index else {
            print("ERROR: Downloaded image's index property is nil.")
            return
        }
        
        spotImages[index] = image
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .none)
        
        let name = googlePlaceCaller.nameAndIndexEncodeToNotificationName(name: self.imageDownloadNotidicationName, index: index)
        let notificationName = Notification.Name(rawValue: name)
        
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
}

