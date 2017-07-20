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
    let serverCommunicate:ServerConnector = ServerConnector()
    let generalModels = GeneralToolModels()
    let shareData = DataManager.shareDataManager
    
    var filter = TripFilter()
    var nDaySchedule: Int!
    var selectedProcess: String!
    var spotItemLabelBGColor = UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1)
    let routeColors = GeneralToolModels.generalColorSetting
    
    let googleMapSchemeStr = "https://www.google.es/maps/dir/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        generalModels.printAllSpotsDetailToDebug(spots: spotData, debugTitle: "viewDidLoad:")
        
        spotData = filter.filtBySpotNDays(nDays: nDaySchedule, trip: data)
        
        checkSpotPosition(spotArray: &spotData)
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploadPocketSpotNotificationDidGet), name: NSNotification.Name(rawValue: "uploadPocketSpotNotifier"), object: nil)
        
        spotItemLabelBGColor = choseColorFromColorArray(date: nDaySchedule, colorArray: routeColors)
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
        
        cell.navigateBtn.tag = indexPath.row
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        cell.cellImage.isHidden = true
        
        cell.spotItemLabel.text = spotData[indexPath.row].spotName  //spotArray[indexPath.row]
        
        cell.spotItemLabel.backgroundColor = spotItemLabelBGColor
        
        cell.spotItemLabel.layer.cornerRadius = 10
        cell.spotItemLabel.layer.masksToBounds = true
        cell.navigateBtn.layer.cornerRadius = 10
        cell.navigateBtn.layer.masksToBounds = true
        cell.navigateBtn.isHidden = false
        
        cell.saveSpotBtn.layer.cornerRadius = 10
        cell.saveSpotBtn.layer.masksToBounds = true
        
        if selectedProcess == "推薦行程" {
            cell.saveSpotBtn.isHidden = false
        } else{
            cell.saveSpotBtn.isHidden = true
        }
        
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
                cell.navigateBtn.isHidden = !cell.navigateBtn.isHidden
            } else{
                cell.describeLabel.text = spotData[indexPath.row].trafficTitle
            }
            
            cellHeightArray.append(cell.describeLabel.frame.height + cell.spotItemLabel.frame.height + 10)
            
        } else{
            cellHeightArray.append(defaultCellHeight)
        }
        
        if cell.describeLabel.text == "" || cell.describeLabel.text == nil || indexPath.row == spotData.count - 1 {
            cell.navigateBtn.isHidden = true
            cell.describeLabel.text = ""
            
        } else{
            // 放入箭頭圖片
            cell.cellImage.isHidden = false
            cell.cellImage.image = UIImage(named: "downArrow2")
        }
        
        return cell
    }
    
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
        
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    @IBAction func navigateButtonBtnPressed(_ sender: UIButton) {
        
        let index = sender.tag
        print(index)
        
        let cellContent = spotData[index]
        let strCoordinate = "\(cellContent.latitude!),\(cellContent.longitude!)"
        //        let strCoordinate = cellContent.spotName!
        //        let strCoordinate = transferAddressString(address: cellContent.spotAddress!)
        let trafficTitleLabelText = cellContent.trafficTitle
        print(strCoordinate)
        print(trafficTitleLabelText)
        
        let destCellContent = spotData[index + 1]
        let destCoordinate = "\(destCellContent.latitude!),\(destCellContent.longitude!)"
        //        let destCoordinate = destCellContent.spotName!
        //        let destCoordinate = transferAddressString(address: destCellContent.spotAddress!)
        print(destCoordinate)
        print(destCellContent.trafficTitle)
        
        let parameterURL = self.parameterURLGenerator(startPoint: strCoordinate, destination: destCoordinate, trafficTitle: trafficTitleLabelText)
        
        if (UIApplication.shared.canOpenURL(URL(string:googleMapSchemeStr)!)) {
            
            let schmemURL = schemeURLGenerator(schmemURL: googleMapSchemeStr, parameterURL: parameterURL)
            UIApplication.shared.openURL(URL(string: schmemURL)!)
            
        } else {
            let schmemURL = schemeURLGenerator(schmemURL: googleMapSchemeStr, parameterURL: parameterURL)
            UIApplication.shared.openURL(URL(string: schmemURL)!)
            print("沒有googleMap唷")
        }
    }
    
    @IBAction func saveSpotBtnPress(_ sender: AnyObject) {
        
        let btnPos = sender.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: btnPos) else {
            print("WARNING: indexPathForRow(at: btnPos) is nil")
            return
        }
        
        let selectSpot = spotData[indexPath.row]
        
        guard shareData.isLogin else {
            print("WARNING: User hasn't login")
            return
        }
        
        guard let pocketSpots = shareData.pocketSpot else {
            print("ERROR: pocketSpot is nil")
            return
        }
        
        if pocketSpots.isEmpty == false {
            
            for spot in pocketSpots {
                
                guard spot.spotName != selectSpot.spotName else {
                    print("WARNING: This spot already in user's pocket")
                    return
                }
            }
        }
        
        selectSpot.spotCountry = data.country
        
        shareData.pocketSpot?.append(selectSpot)
        
        generalModels.customActivityIndicatory(self.view, startAnimate: true)
        
        serverCommunicate.uploadPocketSpotToServer(spotData: selectSpot)
    }
    
    
    func uploadPocketSpotNotificationDidGet() {
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
        generalModels.prepareCommentAlertVC(title: "Success", message: "景點收藏成功")
    }
}

extension ScheduleTableViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func schemeURLGenerator(schmemURL: String, parameterURL: String) -> String {
        return "\(schmemURL)\(parameterURL)"
    }
    
    func parameterURLGenerator(startPoint: String, destination: String, trafficTitle: String) -> String {
        
        //        let travelMod = seperateTravelModString(trafficTitle: trafficTitle)
        let str = "'\(startPoint)'/'\(destination)'"//&directionsmode=\(travelMod)"
        
        return str
    }
    
    fileprivate func transferAddressString(address: String!) -> String {
        
        guard let adrs = address else { return "" }
        let adrsString = adrs.replacingOccurrences(of: " ", with: "+")
        return adrsString
    }
    
    fileprivate func seperateTravelModString(trafficTitle: String) -> String {
        
        let travelTypeString: String
        
        let seperateResult = trafficTitle.components(separatedBy: ",")
        let travleMod = seperateResult[0]
        
        let strSource = RearrangeScheduleVC()
        let strDrivingMod = strSource.drivingTravelTypeLabel
        let strTrasitMod = strSource.transitTravelTypeLabel
        let strWalkingMod = strSource.walkingTravelTypeLabel
        
        switch travleMod {
            
        case strTrasitMod:
            travelTypeString = TravelMod.transit.rawValue.lowercased()
            
        case strDrivingMod:
            travelTypeString = TravelMod.driving.rawValue.lowercased()
            
        case strWalkingMod:
            travelTypeString = TravelMod.walking.rawValue.lowercased()
            
        default:
            travelTypeString = TravelMod.driving.rawValue.lowercased()
        }
        
        return travelTypeString
    }
    
    func choseColorFromColorArray(date: Int, colorArray: [UIColor]) -> UIColor {
    
        let totalColorsCount = colorArray.count
        
        var index = date
        
        if index >= colorArray.count {
            index = index % colorArray.count
        }
        
        return colorArray[index]
    }
}
