//
//  RearrangeScheduleVC.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/26.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GooglePlacePicker
import GoogleMaps

class RearrangeScheduleVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var travelPathWebView: UIWebView!
    @IBOutlet weak var collectionView: UICollectionView!
    // key setting
    fileprivate let keyOfDateCell = "dailyScheduleSetting"
    fileprivate let keyOfScheduleAndTrafficCell = "scheduleArray"
    fileprivate let nameOfFinalScheduleStoryBoard = "Main"
    fileprivate let nameOfFinalScheduleVC = "dailyRouteVC"
    fileprivate let nameOfUploadlScheduleVC = "UploadTripScheduleVC"
    let reuseIdForDateTypeCell = "dateCell"
    let reuseIdForscheduleAndTrafficCell = "scheduleAndTrafficCell"
    let reuseIdForLastAttractionCell = "lastAttractionCell"
    
    fileprivate let currentPageDotTintColor = UIColor.black
    fileprivate let otherPageDotTintColor = UIColor.lightGray
    fileprivate let scheduleTypeCellColor = UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1)
    let goSaveTripPageBtnTitle = "確認規劃"
    let saveTripBtnTitle = "儲存行程"
    let arrowImageName = "downArrow2"
    
    let bikeTravelTypeLabel = "單車"
    let drivingTravelTypeLabel = "開車"
    let walkingTravelTypeLabel = "走路"
    let busTravelTypeLabel = "公車"
    let transitTravelTypeLabel = "捷運/地鐵"
    let defaultTravelTypeLabel = "異常"
    
    let shareData = DataManager.shareDataManager
    var attractions: [Attraction]!
    var routesDetails: [LegsData]!
    var cellContentsArray = [CellContent]()
    var travelDays: Int!
    var tmpTripData = [tripSpotData]()
    var selectedTravelMod: TravelMod!
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let collectionViewLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.minimumLineSpacing = 0
        
        cellContentsArray = prepareCellsContents(attractions: attractions!, routesDetails: routesDetails)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addDateCellBtnPressed(_ sender: UIButton) {
        
        let totalDays = cellContentsArray.filter({$0.type == CustomerCellType.dateCellType}).count
        let newDateCellContent = DateCellContent(dateValue: totalDays + 1)
        cellContentsArray.append(newDateCellContent)
        self.collectionView.reloadData()
    }
    
    fileprivate func prepareCellsContents (attractions:[Attraction], routesDetails:[LegsData]) -> [CellContent] {
        
        var cellsContents = [CellContent]()
        
        for i in 0...attractions.count {
            
            if i == 0 {
                let cellContent = DateCellContent(dateValue: 1)
                cellsContents.append(cellContent)
                
            } else if i == attractions.count {
                
                let cellContent = ScheduleAndTrafficCellContent(attraction: attractions[i-1], trafficInformation: nil, selectedTravelMode: selectedTravelMod)
                cellContent.type = CustomerCellType.lastAttactionCellType
                cellsContents.append(cellContent)
                
            } else {
                
                let cellContent = ScheduleAndTrafficCellContent(attraction: attractions[i-1], trafficInformation: routesDetails[i-1], selectedTravelMode: selectedTravelMod)
                cellsContents.append(cellContent)
            }
        }
        return cellsContents
    }
    
    
    /// Produce the cellContent for next Page
    ///
    /// - Parameter intputArray: the cellContent Array including dateType and scheduleTrafficType cell, whitch we use them with different purples
    /// - Returns:
    ///     - The Array with dictionary type contents:
    ///         - the contens with key - "dailyScheduleSetting": CellContent with dateType.
    ///         - The contens with key - "scheduleArray": CellContent with dateType.
    fileprivate func seperateArrayByDate (intputArray:[CellContent]) -> [[String:Any]]
    {
        //outputArray
        var seperateFinishArray = [[String:Any]]()
        //tmpObj
        var tmpDateCellContent = Int()
        var tmpArray = [ScheduleAndTrafficCellContent]()
        var tmpDic = [String:Any]()
        
        var isFirstObj = true
        
        for obj in intputArray {
            
            if isFirstObj {
                tmpDateCellContent = 1
                isFirstObj = false
                
            } else if obj is DateCellContent {
                //如果是天數type, 將之前的tmpDic＆tmpArray彙整到一天頁面的物件, 並將tmpDic更新為現在這個obj
                tmpDic = [keyOfDateCell:tmpDateCellContent, keyOfScheduleAndTrafficCell:tmpArray]
                seperateFinishArray.append(tmpDic)
                
                tmpDateCellContent = (obj as! DateCellContent).date
                
            } else {
                //是交通＆景點的type, 存到tmpArray中
                let tmpObj = obj as! ScheduleAndTrafficCellContent
                tmpArray += [tmpObj]
                
                if obj == intputArray.last {
                    tmpDic = [keyOfDateCell:tmpDateCellContent, keyOfScheduleAndTrafficCell:tmpArray]
                    seperateFinishArray.append(tmpDic)
                }
            }
        }
        return seperateFinishArray
    }
    
    /// To produce ViewController array that will put into the ScrollView
    ///
    /// - Parameters:
    ///   - myStoryBoard: The StoryBoard where the VC you wanna instantiating is
    ///   - dataArray: The datas to setting the VC's content
    /// - Returns: An array containing all VC you want to instantiate
    func produceVCArray (myStoryBoard: UIStoryboard, cellContents:tripData!) -> [UIViewController] {
        
        var tmpVCArray = [ScheduleTableViewController]()
        
        guard let cellContents = cellContents else {
            print("沒有spot唷")
            return tmpVCArray
        }
        
        travelDays = countTotalTripDays(spot: cellContents.spots)
        
        for i in 0...travelDays - 1 {
            
            let tmpVC = myStoryBoard.instantiateViewController(withIdentifier: nameOfFinalScheduleVC) as! ScheduleTableViewController
            tmpVC.data = cellContents
            tmpVC.nDaySchedule = i + 1
            
            tmpVCArray += [tmpVC]
            print("tmpVCArray=\(tmpVCArray.count)")
        }
        return tmpVCArray
    }
    
    fileprivate func countTotalTripDays (spot:[tripSpotData]) -> Int {
        
        let days = (spot.max{$0.0.nDays < $0.1.nDays})?.nDays
        
        guard let travelDays = days else { return 0 }
        
        return travelDays
    }
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    fileprivate func generateDetailRouteString (route:LegsData!) -> String! {
        
        guard let routeData = route else { return "路線計算錯誤" }
        guard let steps = routeData.steps else { return nil }
        
        var routeDetailString = String()
        var trasitTypeCheck = false
        
        for step in route.steps {
            if step.arrivalStop?.name != "" || step.arrivalStop?.name != nil {
                trasitTypeCheck = true
                break
            }
        }
        
        for i in 0 ... steps.count - 1 {
            let step = steps[i]
            var stepString = "\(i+1). "
            
            if step.arrivalStop != nil {
                stepString += "搭乘\(step.lineAgencies!) - \(step.lineShortame!): \n 從 \(step.departureStop!.name!) 到 \(step.arrivalStop!.name!)\n\n"
                
            } else {
                
                let htmlInstructions = step.htmlInstructions
                
                if htmlInstructions != nil || htmlInstructions != "" {
                    stepString += "\(htmlInstructions!)\n\n"
                } else {
                    stepString = ""
                }
            }
            
            if trasitTypeCheck != true {
                
                if let secondSteps = step.steps {
                    stepString.removeAll()
                    stepString = "\(i+1). "
                    
                    for secondStep in secondSteps {
                        let htmlInstructions = secondStep.htmlInstructions
                        
                        if htmlInstructions != nil || htmlInstructions != "" {
                            let tmpString = "\(htmlInstructions!)\n\n"
                            stepString.append(tmpString)
                        }
                    }
                }
            }
            routeDetailString.append(stepString)
        }
        var returnString = routeDetailString.replacingOccurrences(of: "<div style=\"font-size:0.9em\">", with: "\n註：").replacingOccurrences(of: "</div>", with: "").replacingOccurrences(of: "/", with: "").replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "[", with: "")
        returnString.characters.removeLast(2)
        return returnString
    }
    
    fileprivate func generateRouteTitleString (cellContent:ScheduleAndTrafficCellContent) -> String! {
        
        guard let travelTime = cellContent.trafficTime else { return "時間計算error唷" }
        guard travelTime != "routeCalculate error" else { return "routeCalculate error" }
        guard let travelMod = cellContent.travelMode else { return "交通方式error唷" }
        
        let trafficTypeText: String
        
        switch travelMod{
        case .bike:
            trafficTypeText = bikeTravelTypeLabel
        case .bus:
            trafficTypeText = busTravelTypeLabel
        case .driving:
            trafficTypeText = drivingTravelTypeLabel
        case .walking:
            trafficTypeText = walkingTravelTypeLabel
        case .transit:
            trafficTypeText = transitTravelTypeLabel
        default:
            trafficTypeText = defaultTravelTypeLabel
        }
        
        return "\(trafficTypeText), \(travelTime)"
    }
}


// MARK: - Methods about packaging routes data and taking to the next page.
extension RearrangeScheduleVC {
    
    @IBAction func finishAndNextPage(_ sender: UIBarButtonItem) {
        
        let sb = UIStoryboard(name: nameOfFinalScheduleStoryBoard, bundle: nil)
        let trip = transferCellsContentToTripSpotDataType(cellContent: cellContentsArray)
        shareData.tmpSpotDatas = trip.spots
        let vcArray = produceVCArray(myStoryBoard: sb, cellContents: trip)
        //設定scrollView
        let scrollVCProductor = ProduceScrollViewWithVCArray(vcArrayInput: vcArray)
        scrollVCProductor.pageControlDotExist = true
        scrollVCProductor.currentPageIndicatorTintColorSetting = currentPageDotTintColor
        scrollVCProductor.otherPageIndicatorTintColorSetting = otherPageDotTintColor
        //輸出scrollView
        let scrollView = scrollVCProductor.pagingScrollingVC
        scrollView?.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        let nextPageBtn = UIBarButtonItem(title: goSaveTripPageBtnTitle, style: .plain, target: self, action: #selector(finishScheduleScrollViewAndGoNextPage))
        scrollView?.navigationItem.rightBarButtonItem = nextPageBtn
        
        self.navigationController?.pushViewController(scrollView!, animated: true)
    }
    
    func transferCellsContentToTripSpotDataType(cellContent: [CellContent]) -> tripData {
        
        var spots = [tripSpotData]()
        
        var tmpAttractionData = tripSpotData()
        var tmpDateStorage = 0
        var tmpCellIndexCount = 0
        var tmpList = [Int]()
        
        for i in 0...cellContentsArray.count - 1 {
            if cellContentsArray[i] is DateCellContent && cellContentsArray[i+1] is DateCellContent {
                tmpList.append(i)
            }
        }
        
        let removeList = tmpList.sorted { $0 > $1 }
        
        for i in removeList {
            cellContentsArray.remove(at: i)
        }
        
        if cellContentsArray.last is DateCellContent {
            cellContentsArray.removeLast()
        }
        
        for cellContent in cellContentsArray {
            
            if cellContent is DateCellContent {
                tmpDateStorage += 1
                tmpCellIndexCount = 0
                
            } else if cellContent is ScheduleAndTrafficCellContent {
                
                let cellContentData = cellContent as! ScheduleAndTrafficCellContent
                
                tmpAttractionData.trafficTitle = generateRouteTitleString(cellContent: cellContentData)
                
                tmpAttractionData.spotName = cellContentData.viewPointName!
                tmpAttractionData.nDays = tmpDateStorage
                tmpAttractionData.nTh = tmpCellIndexCount
                tmpAttractionData.trafficToNextSpot = generateDetailRouteString(route: cellContentData.trafficInformation)
                
                tmpAttractionData.placeID = cellContentData.placeID
                tmpAttractionData.latitude = cellContentData.attraction.coordinate.latitude
                tmpAttractionData.longitude = cellContentData.attraction.coordinate.longitude
                tmpAttractionData.spotAddress = cellContentData.address ?? cellContentData.attraction.address
                
                spots.append(tmpAttractionData)
                
                tmpAttractionData = tripSpotData()
                tmpCellIndexCount += 1
                
            } else {
                print("cellContent兩種type都不是唷")
            }
        }
        
        let trip = tripData()
        trip.spots = spots
        return trip
    }
    
    func finishScheduleScrollViewAndGoNextPage() {
        
        let sb = UIStoryboard(name: nameOfFinalScheduleStoryBoard, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: nameOfUploadlScheduleVC) as! UploadTravelScheduleViewController
        vc.travelDays = travelDays
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - CollectionViewController protocol method
extension RearrangeScheduleVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        print("count = \(cellContentsArray.count)")
        return cellContentsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let dayCellSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        let attractionsCellSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
        let lastAttractionsCellSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        
        switch cellContentsArray[indexPath.item].type! {
        case .dateCellType: return dayCellSize
        case .scheduleAndTrafficCellType:
            return attractionsCellSize
        case .lastAttactionCellType:
            return lastAttractionsCellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Check the cell is for prsenting Date or viewPoint and traffic information, then built it.
        switch cellContentsArray[indexPath.item].type! {
        //for presenting Date
        case .dateCellType:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForDateTypeCell, for: indexPath) as! DateCell
            // if is the 1st day cell, show the adding days button
            if indexPath.item == 0 {
                cell.addNewTripDayButton.isHidden = false
            } else {
                cell.addNewTripDayButton.isHidden = true
            }
            // setting the label text
            let cellContent = cellContentsArray[indexPath.item] as! DateCellContent
            cell.dateLabel.text = cellContent.dateStringForLabel
            return cell
            
        //for presenting viewPoint and traffic information
        case .scheduleAndTrafficCellType:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForscheduleAndTrafficCell, for: indexPath) as! ScheduleAndTrafficCell
            // setting the label text
            let cellContent = cellContentsArray[indexPath.item] as! ScheduleAndTrafficCellContent
            
            cell.viewPointName.text = cellContent.viewPointName
            
            cell.viewPointBGBlock.layer.cornerRadius = 10
            cell.viewPointBGBlock.backgroundColor = scheduleTypeCellColor
//            cell.arrow.layer.cornerRadius = 10
//            cell.arrow.backgroundColor = scheduleTypeCellColor
            
            cell.arrow.image = UIImage(named: arrowImageName)
            
            
            cell.trafficInf.text = generateRouteTitleString(cellContent: cellContent)
            
            return cell
            
        case .lastAttactionCellType:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForLastAttractionCell, for: indexPath) as! LastAttractionCell
            let cellContent = cellContentsArray[indexPath.item] as! ScheduleAndTrafficCellContent
            cell.viewPointName.text = cellContent.viewPointName
            cell.viewPointBGBlock.layer.cornerRadius = 10
            cell.viewPointBGBlock.backgroundColor = scheduleTypeCellColor
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        var result = true
        if indexPath.item == 0 { result = false }
        
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard sourceIndexPath != destinationIndexPath else {
            print("沒動cell唷")
            return
        }
        
        let srcIndex = sourceIndexPath.item
        let srcPreIndex = srcIndex - 1
        let srcNextIndex = srcIndex + 1
        
        let dstIndex = (destinationIndexPath.item != 0 ? destinationIndexPath.item: 1)
        let dstPreIndex = dstIndex - 1
        let dstNextIndex = dstIndex + 1
        
        // 關於移走的cell的變動
        if srcPreIndex > 0 {
            if cellContentsArray[srcPreIndex] is ScheduleAndTrafficCellContent {   //如果前一個是交通格式交通格式, 處理前一個屬性
                var previousCellContent = cellContentsArray[srcPreIndex] as! ScheduleAndTrafficCellContent
                
                if srcNextIndex <= cellContentsArray.count - 1 {
                    if cellContentsArray[srcNextIndex] is ScheduleAndTrafficCellContent { //如果下一個不是是日期格式
                        previousCellContent.type = CustomerCellType.scheduleAndTrafficCellType
                        
                        let destination = (cellContentsArray[srcNextIndex] as! ScheduleAndTrafficCellContent).attraction.placeID
                        getNewTrafficDetail(targetCellContent: &previousCellContent,
                                            destinationPlaceID: destination!,
                                            completion: { (legsData) in previousCellContent.setTrafficValue(legsData: legsData) })
                    } else {    // 如果下一個是日期格式
                        transferToLastAttrCellContent(targetCellContent: &previousCellContent)
                    }
                } else {
                    transferToLastAttrCellContent(targetCellContent: &previousCellContent)
                }
            }
        }
        
        let movedCellContent = cellContentsArray.remove(at: srcIndex)
        cellContentsArray.insert(movedCellContent, at: dstIndex)
        
        // 關於插入Cell後的動作
        if cellContentsArray[dstIndex] is ScheduleAndTrafficCellContent { //在移動的是交通模式
            
            var movedCellContent = cellContentsArray[dstIndex] as! ScheduleAndTrafficCellContent
            //如果前一個cell是交通模式, 變更前一個的CellType, 並重算前一個的交通
            if dstPreIndex > 0 {
                
                if  cellContentsArray[dstPreIndex] is ScheduleAndTrafficCellContent {
                    //                    print("移動後前一個是交通唷")
                    var dstPreCellContent = cellContentsArray[dstPreIndex] as! ScheduleAndTrafficCellContent
                    dstPreCellContent.type = CustomerCellType.scheduleAndTrafficCellType
                    
                    
                    let destination = movedCellContent.attraction.placeID
                    getNewTrafficDetail(targetCellContent: &dstPreCellContent,
                                        destinationPlaceID: destination!,
                                        completion: { (legsData) in
                                            dstPreCellContent.setTrafficValue(legsData: legsData)
                                            self.collectionView.reloadData()
                    })
                }
            }
            
            if dstNextIndex <= cellContentsArray.count - 1 {
                if cellContentsArray[dstNextIndex] is ScheduleAndTrafficCellContent {
                    //                    print("移動後本身是交通唷")
                    
                    let nextCellContent = cellContentsArray[dstNextIndex] as! ScheduleAndTrafficCellContent
                    getNewTrafficDetail(targetCellContent: &movedCellContent,
                                        destinationPlaceID: nextCellContent.attraction.placeID,
                                        completion: { (legsData) in
                                            movedCellContent.setTrafficValue(legsData: legsData)
                                            self.collectionView.reloadData()
                    })
                    
                } else {
                    transferToLastAttrCellContent(targetCellContent: &movedCellContent)
                    self.collectionView.reloadData()
                }
            } else {
                transferToLastAttrCellContent(targetCellContent: &movedCellContent)
                self.collectionView.reloadData()
            }
        } else {
            // 如果前面是traffic, 將traffic inf設為nil, 並變更type為last
            if dstPreIndex >= 0 {
                
                if  cellContentsArray[dstPreIndex] is ScheduleAndTrafficCellContent {
                    //                    print("移動後前一個是交通唷")
                    var dstPreCellContent = cellContentsArray[dstPreIndex] as! ScheduleAndTrafficCellContent
                    transferToLastAttrCellContent(targetCellContent: &dstPreCellContent)
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    func transferToLastAttrCellContent (targetCellContent: inout ScheduleAndTrafficCellContent) {
        targetCellContent.type = CustomerCellType.lastAttactionCellType
        targetCellContent.trafficInformation = nil
        targetCellContent.trafficTime = nil
    }
    
    func getNewTrafficDetail (targetCellContent: inout ScheduleAndTrafficCellContent,
                              destinationPlaceID: String,
                              completion: @escaping ( _ routeInformation:LegsData) -> Void) {
        
        targetCellContent.type = CustomerCellType.scheduleAndTrafficCellType
        
        let googleDirectCaller = GoogleDirectionCaller()
        googleDirectCaller.getRouteInformation(origin: targetCellContent.attraction.placeID,
                                               destination: destinationPlaceID) { (responseLegsData) in
                                                completion(responseLegsData)
        }
    }
}

// MARK: - modify another one's class
extension ScheduleTableViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
}



// MARK: - 待建立.swift的model
class DataTypeTransformer {
    
    func transferGMPlaceToSpotDataType(obj: GMSPlace) -> spotData {
        
        let spotObj = spotData()
        spotObj.spotName = obj.name
        spotObj.placeID = obj.placeID
        spotObj.latitude = obj.coordinate.latitude
        spotObj.longitude = obj.coordinate.longitude
        return spotObj
    }
    
    
    func transferSpotDataToAttractionsType(obj: spotData) -> Attraction {
        
        var attr = Attraction()
        attr.attrctionName = obj.spotName
        attr.placeID = obj.placeID
        let coordinate = CLLocationCoordinate2D(latitude: obj.latitude!, longitude: obj.longitude!)
        attr.coordinate = coordinate
        
        return attr
    }
    
    
    func transferAttractionToSpotDataTypeType(obj: Attraction) -> spotData {
        
        let spotObj = spotData()
        spotObj.spotName = obj.attrctionName
        spotObj.placeID = obj.placeID
        spotObj.latitude = obj.coordinate.latitude
        spotObj.longitude = obj.coordinate.longitude
        return spotObj
    }
    
    
    func setValueToAttractionsList(placeList: [GMSPlace]) -> [Attraction] {
        
        var attractionsList = [Attraction]()
        
        for place in placeList {
            var tmpAttraction = Attraction()
            tmpAttraction.setValueToAttractionObject(place: place)
            attractionsList.append(tmpAttraction)
        }
        return attractionsList
    }
    
    
    func setValueToAtrractionListFromSpotList(spotList: [spotData]) -> [Attraction] {
        
        var attractionsList = [Attraction]()
        
        for spot in spotList {
            let attr = transferSpotDataToAttractionsType(obj: spot)
            attractionsList.append(attr)
        }
        return attractionsList
    }
    
    
    func setValueToSpotDataList(attractionList: [Attraction]!) -> [spotData]! {
        
        guard !attractionList.isEmpty else { return nil }
        
        var spotList = [spotData]()
        for i in 0 ... attractionList.count - 1 {
            let spot = transferAttractionToSpotDataTypeType(obj: attractionList[i])
            spotList.append(spot)
        }
        return spotList
    }
}

struct GooglePlacePickerGenerator {
    
    func generatePlacePicker(selectedCountry: String) -> GMSPlacePicker {
        
        let tmpCountry = self.selectCountryTypeTrasformer(selectedCountry: selectedCountry)
        var bounds: GMSCoordinateBounds? = nil
        
        if let country = tmpCountry {
            let coordinateNE = getBoundCoordinate(selectedCountry: country, space: .positive)
            let coordinateWS = getBoundCoordinate(selectedCountry: country, space: .negative)
            
            let path = GMSMutablePath()
            path.add(coordinateNE)
            path.add(coordinateWS)
            
            bounds = GMSCoordinateBounds(path: path)
        }
        
        let config = GMSPlacePickerConfig(viewport: bounds)
        let placePicker = GMSPlacePicker(config: config)
        
        return placePicker
    }
    
    
    private func getBoundCoordinate(selectedCountry: BoundsCoordinate, space: Space) -> CLLocationCoordinate2D {

        let seperateResult = selectedCountry.rawValue.components(separatedBy: ",")
        let spaceValue = 0.01
        let lat: Double
        let lng: Double
        
        if space == .positive {
            lat = Double(seperateResult[0])! + spaceValue
            lng = Double(seperateResult[1])! + spaceValue
        } else {
            lat = Double(seperateResult[0])! - spaceValue
            lng = Double(seperateResult[1])! - spaceValue
        }
        
        return CLLocationCoordinate2DMake(lat, lng)
    }
    
    
    private func selectCountryTypeTrasformer(selectedCountry: String) -> BoundsCoordinate! {
        
        let countryList: [String: BoundsCoordinate] = ["台灣":.臺灣,"日本":.日本,"香港":.香港,"韓國":.韓國,"中國":.中國,
                                                       "新加坡":.新加坡,"泰國":.泰國,"菲律賓":.菲律賓,
                                                       "英國":.英國,"法國":.法國,"德國":.德國,"西班牙":.西班牙,
                                                       "瑞士":.瑞士,"冰島":.冰島,"芬蘭":.芬蘭,"義大利":.義大利,
                                                       "美國":.美國,"加拿大":.加拿大,
                                                       "委內瑞拉":.委內瑞拉,"巴西":.巴西,"阿根廷":.阿根廷,
                                                       "澳大利亞":.澳洲,"紐西蘭":.新西蘭 ]
        
        let country = countryList[selectedCountry]
        return country!
    }
}

enum BoundsCoordinate: String {
    
    case 香港 = "22.2768196,114.1681163,16z",
    日本 = "35.668864,139.4611935,10z",
    韓國 = "37.5647689,126.7093638,10z",
    中國 = "39.9375346,115.837023,9z",
    臺灣 = "25.0498002,121.5363940,11z",
    新加坡 = "1.314715,103.5668226,10z",
    泰國 = "13.7244426,100.3529157,10z",
    菲律賓 = "14.5964879,120.9094042,12z",
    英國 = "51.528308,-0.3817961,10z",
    法國 = "48.8587741,2.2074741,11z",
    德國 = "59.3258414,17.7073729,10z",
    西班牙 = "40.4378698,-3.8196207,11z",
    瑞士 = "46.9545845,7.2547869,11z",
    冰島 = "64.1322134,-21.9925226,11z",
    芬蘭 = "60.1637088,24.7600957,10z",
    義大利 = "41.9097306,12.2558141,10z",
    美國 = "38.8993276,-77.0847778,12z",
    加拿大 = "45.2487862,-76.3606792,9z",
    委內瑞拉 = "10.4683612,-67.0304525,11z",
    巴西 = "-15.6936233,-47.9963963,10.25z",
    阿根廷 = "-34.6156541,-58.5734051,11z",
    澳洲 = "-35.2813043,149.1204446,15z",
    新西蘭 = "-41.2442852,174.6217707,11z"
}

enum Space {
    case positive, negative
}

