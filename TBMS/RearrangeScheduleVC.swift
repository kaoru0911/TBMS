//
//  RearrangeScheduleVC.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/26.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GooglePlaces
import GooglePlacePicker
import GoogleMaps

class RearrangeScheduleVC: UIViewController {
    
    // MARK: Keys
    fileprivate let keyOfDateCell = "dailyScheduleSetting"
    fileprivate let keyOfScheduleAndTrafficCell = "scheduleArray"
    fileprivate let nameOfFinalScheduleStoryBoard = "Main"
    fileprivate let nameOfFinalScheduleVC = "dailyRouteVC"
    fileprivate let nameOfUploadlScheduleVC = "UploadTripScheduleVC"
    
    let reuseIdForDateTypeCell = "dateCell"
    let reuseIdForscheduleAndTrafficCell = "scheduleAndTrafficCell"
    let reuseIdForLastAttractionCell = "lastAttractionCell"
    
    fileprivate let goSaveTripPageBtnTitle = "確認規劃"
    fileprivate let saveTripBtnTitle = "儲存行程"
    fileprivate let arrowImageName = "downArrow2"
    
    fileprivate let pinImageFileName = "annotation.png"
    
    let bikeTravelTypeLabel = "單車"
    let drivingTravelTypeLabel = "開車"
    let walkingTravelTypeLabel = "走路"
    let busTravelTypeLabel = "公車"
    let transitTravelTypeLabel = "捷運/地鐵"
    let defaultTravelTypeLabel = "異常"
    
    // MARK:- Values
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    
    let shareData = DataManager.shareDataManager
    let generalModels = GeneralToolModels()
    
    var attractions: [Attraction]!
    var routesDetails: [LegsData]!
    var selectedTravelMod: TravelMod!
    
    fileprivate var cellContentsArray = [CellContent]()
    fileprivate var travelDays: Int!
    fileprivate var tmpTripData = [tripSpotData]()
    fileprivate var swipedCell : DateCell!
    
    fileprivate let textPtYRatio: CGFloat = 2/79
    fileprivate let textfontSetting = UIFont(name: "Helvetica Bold", size: 20)
    
    fileprivate let currentPageDotTintColor = UIColor.black
    fileprivate let otherPageDotTintColor = UIColor.lightGray
    fileprivate let scheduleTypeCellColor = UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1)
    fileprivate var routeColors = GeneralToolModels.generalColorSetting
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViewGesture()
        
        // Setting cells space
        let collectionViewLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.minimumLineSpacing = 0
        
        // Prepare cells display contents
        cellContentsArray = prepareCellsContents(attractions: attractions!, routesDetails: routesDetails)
        prepareCellsColor(cellContents: cellContentsArray)
        
        // Setting the routeMapRegion & annotation
        map.delegate = self
        routeMapGenerator(attractions: attractions)
        // general the image whitch will display on the top
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addDateCellBtnPressed(_ sender: UIButton) {
        
        let dayCellsCount = cellContentsArray.filter({$0.type == CustomerCellType.dateCellType}).count
        let newDateCellContent = DateCellContent(dateValue: dayCellsCount + 1)
        cellContentsArray.append(newDateCellContent)
        
        self.collectionView.reloadData()
        
        let lastIndex = IndexPath(item: cellContentsArray.count - 1, section: 0)
        self.collectionView.scrollToItem(at: lastIndex, at: UICollectionViewScrollPosition.centeredVertically, animated: true)
    }
    
    
    @IBAction func deleteDateCellBtnPressed(_ sender: UIButton) {
        
        let targetCellIndex = IndexPath(item: sender.tag, section: 0)
        removeCell(cellIndex: targetCellIndex)
        
        prepareCellsColor(cellContents: self.cellContentsArray)
        reloadDataAndResetCellsDate()
    }
    
    
    /// Initialize the cells contents
    ///
    /// - Parameters:
    ///   - attractions: Attractions list.
    ///   - routesDetails: Route details between each attractions.
    /// - Returns: Cells content array
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
    
    fileprivate func prepareCellsColor(cellContents:[CellContent]) {
        
        var colorIndex = 0
        
        for i in 0 ... cellContents.count - 1 {
            
            let cellContent = cellContents[i]
            
            if colorIndex > routeColors.count {
                colorIndex = colorIndex % routeColors.count
            }
            
            cellContent.cellColor = routeColors[colorIndex]
            
            guard i+1 < cellContents.count else { continue }
            
            if cellContent is DateCellContent && (cellContents[i+1] is DateCellContent) == false {
                colorIndex += 1
            }
        }
        
    }
    
    
    /// To generate a complete route informationfor the property "goToNextSpot" of the spot-data type object.
    ///
    /// - Parameter route: The response data from google direction like the property trafficInformation of the cell content data
    /// - Returns: The complete route information string including each step of the route.
    fileprivate func generateDetailRouteString (route:LegsData!) -> String! {
        
        guard let routeData = route else { return "路線計算異常" }
        guard let steps = routeData.steps else { return nil }
        
        var routeDetailString = String()
        var trasitTypeChecking = false
        
        // Check the route's travel mode is transit or anothers.
        for step in route.steps {
            
            if step.arrivalStop?.name != "" || step.arrivalStop?.name != nil {
                trasitTypeChecking = true
                break
            }
        }
        
        
        for i in 0 ... steps.count - 1 {
            
            let step = steps[i]
            var stepString = "\(i+1). "
            
            // Check if
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
            
            if trasitTypeChecking != true {
                
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
        
        var returnString = routeDetailString
            .replacingOccurrences(of: "<div style=\"font-size:0.9em\">", with: "\n註：")
            .replacingOccurrences(of: "</div>", with: "")
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "[", with: "")
        
        returnString.characters.removeLast(2)
        
        // If there's only one step, remove the number of the step.
        if steps.count == 1 {
            returnString.characters.removeFirst(3)
        }
        
        return returnString
    }
    
    
    
    /// To generate the short route information for the property "route title" of the spot data
    ///
    /// - Parameter cellContent: The cell-content type object witch wants to generate the shorter route information for the next page.
    /// - Returns: The shorter route information for displaying on the next page.
    fileprivate func generateRouteTitleString (cellContent:ScheduleAndTrafficCellContent) -> String! {
        
        guard let travelTime = cellContent.trafficTime else { return "時間重新計算中"/*時間計算error唷*/ }
        guard travelTime != "routeCalculate error" else { return "路線重新計算中"/*routeCalculate error*/ }
        guard let travelMod = cellContent.travelMode else { return "交通方式異常" }
        
        let selfTravelMod = self.selectedTravelMod
        let trafficTypeText: String
        
        guard selfTravelMod != .driving else {
            print("駕駛模式囉")
            trafficTypeText = drivingTravelTypeLabel
            return "\(trafficTypeText), \(travelTime)"
        }
        
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
    
    // MARK: Methods to handle gestures in collectionView.
    func setupViewGesture(){
        
        // Setting up long press gesture to let cell be movable.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        
        // Setting up swipe gesture recognizer
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeftGesture(_:)))
        swipeLeft.direction = .left
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRightGesture))
        swipeRight.direction = .right
        
        collectionView.addGestureRecognizer(longPress)
        collectionView.addGestureRecognizer(swipeLeft)
        collectionView.addGestureRecognizer(swipeRight)
    }
    
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else { break }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
            
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    
    func handleSwipeLeftGesture(_ gesture : UISwipeGestureRecognizer){
        
        let point = gesture.location(in: collectionView)
        
        guard let cell = getCellAtPoint(point) else { return }
        
        guard let firstCellContent = cellContentsArray[0] as? DateCellContent else {
            print("ERROR: 1st cell isn't DateCell")
            return
        }
        
        guard cell.dateLabel.text != firstCellContent.dateStringForLabel else { return }
        
        let duration = animationDuration()
        let moveSpace: CGFloat = cell.deleteBtn.frame.width
        
        if (swipedCell == nil) {
            
            swipedCell = cell
            UIView.animate(withDuration: duration, animations: {
                self.swipedCell.cellContentBlock.transform = CGAffineTransform(translationX: -moveSpace, y: 0)
            })
            
        } else {
            
            // It's not the same cell that is swiped, so the previously selected cell will get unswiped and the new swiped.
            UIView.animate(withDuration: duration,
                           animations: {
                            self.swipedCell.cellContentBlock.transform = CGAffineTransform.identity
                            cell.cellContentBlock.transform = CGAffineTransform(translationX: -moveSpace, y: 0) },

                           completion: { (Void) in self.swipedCell = cell })
        }
    }
    
    func handleSwipeRightGesture(){
        // Revert back
        if(swipedCell != nil){
            let duration = animationDuration()
            
            UIView.animate(withDuration: duration,
                           animations: {
                            self.swipedCell.cellContentBlock.transform = CGAffineTransform.identity },
                           completion: { (Void) in self.swipedCell = nil })
        }
    }
    
    private func getCellAtPoint(_ point: CGPoint) -> DateCell? {
        
        // Function for getting item at point. Note optionals as it could be nil
        let indexPath = collectionView.indexPathForItem(at: point)
        guard indexPath != nil else { return nil }
        
        guard let cell = collectionView.cellForItem(at: indexPath!) as? DateCell else { return nil }
        
        return cell
    }
    
    private func animationDuration() -> Double {
        return 0.5
    }
}


// MARK: - Methods about packaging routes data and taking to the next page.

extension RearrangeScheduleVC {
    
    @IBAction func finishAndNextPage(_ sender: UIBarButtonItem) {
        
        // Prepare all the Views with View Controllers which we want to display on the scrollView
        let sb = UIStoryboard(name: nameOfFinalScheduleStoryBoard, bundle: nil)
        let trip = tripDataGenerator(cellContents: cellContentsArray)
        shareData.tmpSpotDatas = trip.spots
        let vcArray = produceVCArray(myStoryBoard: sb, cellContents: trip)
        
        // ScrollView config setting
        let scrollVCProductor = ProduceScrollViewWithVCArray(vcArrayInput: vcArray)
        scrollVCProductor.pageControlDotExist = true
        scrollVCProductor.currentPageIndicatorTintColorSetting = currentPageDotTintColor
        scrollVCProductor.otherPageIndicatorTintColorSetting = otherPageDotTintColor
        
        // Generate the scrollView
        let scrollView = scrollVCProductor.pagingScrollingVC
        scrollView?.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        // Generate the "goNextPage" Btn
        let nextPageBtn = UIBarButtonItem(title: goSaveTripPageBtnTitle, style: .plain, target: self, action: #selector(finishPlanningAndGoToNextPage))
        scrollView?.navigationItem.rightBarButtonItem = nextPageBtn
        
        // Present the scrollView
        self.navigationController?.pushViewController(scrollView!, animated: true)
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
    
    
    /// To transfer cellContent Objct to the tripData type objct.
    func tripDataGenerator(cellContents: [CellContent]) -> tripData {
        
        var spots = [tripSpotData]()
        
        var tmpAttractionData = tripSpotData()
        var tmpDateStorage = 0
        var tmpCellIndexCount = 0
        
        let filteredCellContents = filterSuperfluousDateCellContents(cellContents: cellContents)
        
        for cellContent in filteredCellContents {
            
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
    
    fileprivate func filterSuperfluousDateCellContents(cellContents: [CellContent]) -> [CellContent] {
        
        var removeList = [Int]()
        var filteredcellContents = cellContents
        
        for i in 0...cellContents.count - 1 {
            
            guard i - 1 >= 0 else { continue }
            
            if cellContents[i-1] is DateCellContent && cellContents[i] is DateCellContent {
                removeList.insert(i, at: 0)
            }
        }
        
        for i in removeList {
            filteredcellContents.remove(at: i)
        }
        
        if cellContentsArray.last is DateCellContent {
            filteredcellContents.removeLast()
        }
        
        return filteredcellContents
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
            print("ERROR: SpotData doesn't exist")
            return tmpVCArray
        }
        
        travelDays = countTotalTripDays(spot: cellContents.spots)
        
        for i in 0...travelDays - 1 {
            
            let tmpVC = myStoryBoard.instantiateViewController(withIdentifier: nameOfFinalScheduleVC) as! ScheduleTableViewController
            tmpVC.data = cellContents
            tmpVC.nDaySchedule = i + 1
            tmpVC.selectedProcess = ""
            
            tmpVCArray += [tmpVC]
            print("tmpVCArray=\(tmpVCArray.count)")
        }
        
        return tmpVCArray
    }
    
    
    /// Countting Day-type cells amount for next page.
    ///
    /// - Parameter spot: Spots array trasfer from attractions array including date property.
    /// - Returns: Total travel days
    fileprivate func countTotalTripDays (spot:[tripSpotData]) -> Int {
        
        let days = (spot.max{$0.0.nDays < $0.1.nDays})?.nDays
        
        guard let travelDays = days else { return 0 }
        
        return travelDays
    }
    
    
    @objc fileprivate func finishPlanningAndGoToNextPage() {
        
        let sb = UIStoryboard(name: nameOfFinalScheduleStoryBoard, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: nameOfUploadlScheduleVC) as! UploadTravelScheduleViewController
        vc.travelDays = travelDays
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - CollectionViewController protocol method
extension RearrangeScheduleVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cellContentsArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let dayCellSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        let attractionsCellSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
        let lastAttractionsCellSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        
        switch cellContentsArray[indexPath.item].type! {
            
        case .dateCellType: return dayCellSize
            
        case .scheduleAndTrafficCellType: return attractionsCellSize
            
        case .lastAttactionCellType: return lastAttractionsCellSize
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Check the cell is for prsenting Date or for presenting viewPoint and traffic information, then built it.
        switch cellContentsArray[indexPath.item].type! {
            
        case .dateCellType:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForDateTypeCell, for: indexPath) as! DateCell
            
            if indexPath.item == 0 {

                cell.addNewTripDayButton.isHidden = false
                
            } else {
                
                cell.addNewTripDayButton.isHidden = true
            }
            
            // setting the label text
            let cellContent = cellContentsArray[indexPath.item] as! DateCellContent
            cell.dateLabel.text = cellContent.dateStringForLabel
            cell.dateLabel.font = UIFont.boldSystemFont(ofSize: 24)
            cell.deleteBtn.tag = indexPath.item
            
            cell.cellContentBlock.transform = CGAffineTransform.identity
            
            return cell
            
            
        case .scheduleAndTrafficCellType:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForscheduleAndTrafficCell, for: indexPath) as! ScheduleAndTrafficCell
            // setting the label text
            let cellContent = cellContentsArray[indexPath.item] as! ScheduleAndTrafficCellContent
            
            cell.viewPointName.text = cellContent.viewPointName
            cell.viewPointName.lineBreakMode = .byTruncatingTail
            
            cell.arrow.image = UIImage(named: arrowImageName)
            cell.trafficInf.text = generateRouteTitleString(cellContent: cellContent)
            
            cell.viewPointBGBlock.layer.cornerRadius = 10
            cell.viewPointBGBlock.backgroundColor = cellContent.cellColor//scheduleTypeCellColor
            
            return cell
            
            
        case .lastAttactionCellType:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForLastAttractionCell, for: indexPath) as! LastAttractionCell
            let cellContent = cellContentsArray[indexPath.item] as! ScheduleAndTrafficCellContent
            
            cell.viewPointName.text = cellContent.viewPointName
            cell.viewPointName.lineBreakMode = .byTruncatingTail
            
            cell.viewPointBGBlock.layer.cornerRadius = 10
            cell.viewPointBGBlock.backgroundColor = cellContent.cellColor//scheduleTypeCellColor
            
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
            print("Cell doesn't move")
            return
        }
        
        // 關於移走的cell的變動
        let movedCellContent = removeCell(cellIndex: sourceIndexPath)
        insertCell(insertCellContent: movedCellContent, destinationIndexPath: destinationIndexPath)
        
        let (newAnnotations,newGeodesics) = createAnnotationsAndGeodesics(cellContents: cellContentsArray)
        
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
        map.addAnnotations(newAnnotations)
        map.addOverlays(newGeodesics)
        
        print(self.collectionView.visibleCells)
    }
    
    
    fileprivate func removeCell(cellIndex: IndexPath) -> CellContent {
        
        let srcIndex = cellIndex.item
        let srcPreIndex = srcIndex - 1
        let srcNextIndex = srcIndex + 1
        
        if srcPreIndex > 0 {
            
            if cellContentsArray[srcPreIndex] is ScheduleAndTrafficCellContent {   //如果前一個是交通格式交通格式, 處理前一個屬性
                
                var previousCellContent = cellContentsArray[srcPreIndex] as! ScheduleAndTrafficCellContent
                
                if srcNextIndex <= cellContentsArray.count - 1
                    && cellContentsArray[srcNextIndex] is ScheduleAndTrafficCellContent {
                    
                    //如果下一個不是是日期格式
                    previousCellContent.type = CustomerCellType.scheduleAndTrafficCellType
                    
                    let destination = (cellContentsArray[srcNextIndex] as! ScheduleAndTrafficCellContent).attraction
                    getNewTrafficDetail(targetCellContent: &previousCellContent,
                                        destination: destination!,
                                        completion: {
                                            (legsData) in
                                            previousCellContent.setTrafficValue(legsData: legsData)
                                            self.collectionView.reloadData() })
                } else {
                    
                    transferToLastAttrCellContent(targetCellContent: &previousCellContent)
                }
            }
        }
        return cellContentsArray.remove(at: srcIndex)
    }
    
    
    private func insertCell (insertCellContent: CellContent, destinationIndexPath: IndexPath) {
        
        let dstIndex = (destinationIndexPath.item != 0 ? destinationIndexPath.item: 1)
        let dstPreIndex = dstIndex - 1
        let dstNextIndex = dstIndex + 1
        
        cellContentsArray.insert(insertCellContent, at: dstIndex)
        
        // 關於插入Cell後的動作
        if cellContentsArray[dstIndex] is ScheduleAndTrafficCellContent { //在移動的是交通模式
            
            var movedCellContent = cellContentsArray[dstIndex] as! ScheduleAndTrafficCellContent
            //如果前一個cell是交通模式, 變更前一個的CellType, 並重算前一個的交通
            if dstPreIndex > 0 && cellContentsArray[dstPreIndex] is ScheduleAndTrafficCellContent {
                
                var dstPreCellContent = cellContentsArray[dstPreIndex] as! ScheduleAndTrafficCellContent
                dstPreCellContent.type = CustomerCellType.scheduleAndTrafficCellType
                
                let destination = movedCellContent.attraction
                getNewTrafficDetail(targetCellContent: &dstPreCellContent,
                                    destination: destination!,
                                    completion: { (legsData) in
                                        
                                        dstPreCellContent.setTrafficValue(legsData: legsData)
                                        self.collectionView.reloadData()
                })
            }
            
            if dstNextIndex <= cellContentsArray.count - 1
                && cellContentsArray[dstNextIndex] is ScheduleAndTrafficCellContent {
                
                let nextCellContent = cellContentsArray[dstNextIndex] as! ScheduleAndTrafficCellContent
                getNewTrafficDetail(targetCellContent: &movedCellContent,
                                    destination: nextCellContent.attraction,
                                    completion: { (legsData) in
                                        
                                        movedCellContent.setTrafficValue(legsData: legsData)
                                        self.collectionView.reloadData()
                })
                
            } else {
                
                transferToLastAttrCellContent(targetCellContent: &movedCellContent)
            }
            
            self.prepareCellsColor(cellContents: self.cellContentsArray)
            self.collectionView.reloadData()
            
        } else {
            
            // 如果前面是traffic, 將traffic inf設為nil, 並變更type為last
            if dstPreIndex >= 0 && cellContentsArray[dstPreIndex] is ScheduleAndTrafficCellContent {
                var dstPreCellContent = cellContentsArray[dstPreIndex] as! ScheduleAndTrafficCellContent
                transferToLastAttrCellContent(targetCellContent: &dstPreCellContent)
            }
            
            reloadDataAndResetCellsDate()
        }
    }
    
    
    private func transferToLastAttrCellContent (targetCellContent: inout ScheduleAndTrafficCellContent) {
        
        targetCellContent.type = CustomerCellType.lastAttactionCellType
        targetCellContent.trafficInformation = nil
        targetCellContent.trafficTime = nil
    }
    
    
    private func getNewTrafficDetail (targetCellContent: inout ScheduleAndTrafficCellContent,
                                      destination: Attraction,
                                      completion: @escaping ( _ routeInformation:LegsData) -> Void) {
        
        targetCellContent.type = CustomerCellType.scheduleAndTrafficCellType
        
        let googleDirectCaller = GoogleDirectionCaller()
        googleDirectCaller.parametersSetting.travelMod = selectedTravelMod
        googleDirectCaller.getRouteInformation(origin: targetCellContent.attraction,
                                               destination: destination) { (responseLegsData) in
                                                completion(responseLegsData)
        }
    }
    
    
    fileprivate func reloadDataAndResetCellsDate() {
        
        var date = 1
        
        for cellContent in cellContentsArray {
            
            if cellContent is DateCellContent {
                (cellContent as! DateCellContent).date = date
                date += 1
            }
        }
        
        prepareCellsColor(cellContents: cellContentsArray)
        
        self.collectionView.reloadData()
    }
}


// MARK: - Methods for Annotation & MKMapViewDelegate protocol
extension RearrangeScheduleVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 2.5
        
        guard let indexString = renderer.polyline.subtitle else {
            
            print("index不存在唷")
            renderer.strokeColor = routeColors[1]
            return renderer
        }
        
        let geoIndex = Int(indexString) ?? 0
        print("geoIndex = \(geoIndex)")
        let colorIndex = (geoIndex + 1) % routeColors.count
        
        renderer.strokeColor = routeColors[colorIndex]
        
        return renderer
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let myAnnotation = annotation as? CustomerAnnotation else {
            print("ERROR: Annotation ")
            return MKAnnotationView(annotation: annotation, reuseIdentifier: "none")
        }
        
        
        let annotationID = String(myAnnotation.tag ?? 0)
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID)
        
        if result == nil {
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            
            let image = UIImage(named: self.pinImageFileName)
            let pinImg = producePinImg( text: annotationID,
                                        annotationImg: image! )
            
            guard let img = pinImg else {
                
                print("ERROR: Image file of pin doesn't exist!!")
                result?.image = image
                return result
            }
            
            result?.image = img
            
        } else {
            result?.annotation = annotation
        }
        
        result?.canShowCallout = true
//        result?.detailCalloutAccessoryView?.isHidden = true /// 隱藏細節失敗
        return result
    }
    
    
    fileprivate func routeMapGenerator(attractions: [Attraction]) {
        
        if map.annotations.isEmpty != true {
            map.remove(map.overlays as! MKOverlay)
            map.removeAnnotations(map.annotations)
        }
        
        var showCalloutAnnotation: CustomerAnnotation?
        
        var points = [CLLocationCoordinate2D]()
        var latSum = Double()
        var lngSum = Double()
        
        for i in 0...attractions.count - 1 {
            
            let attr = attractions[i]
            
            guard let point = attr.coordinate else {
                print("attr.coordinate isn't exist.")
                return
            }
            
            points.append(point)
            
            latSum += Double(point.latitude)
            lngSum += Double(point.longitude)
            
            let annotation = createAnnotation(attraction: attr, attrIndex: i)
            map.addAnnotation(annotation)
            
            if i == 0 {
                showCalloutAnnotation = annotation
            }
        }
        
        let totalPoints = Double(map.annotations.count)
        let center = CLLocationCoordinate2DMake(latSum/totalPoints, lngSum/totalPoints)
        
        var maxLatSpec = 0.0
        var maxLngSpec = 0.0
        
        for point in map.annotations {
            
            let coordinate = point.coordinate
            let latSpec = abs(coordinate.latitude - center.latitude)
            let lngSpec = abs(coordinate.longitude - center.longitude)
            
            maxLatSpec = max(latSpec, maxLatSpec)
            maxLngSpec = max(lngSpec, maxLngSpec)
        }
        
        let span = MKCoordinateSpan(latitudeDelta: maxLatSpec * 2, longitudeDelta: maxLngSpec * 2)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: true)
        
        let geodesic = MKGeodesicPolyline(coordinates: points, count: points.count)
        map.add(geodesic)
        
        guard let targetAnnotation = showCalloutAnnotation else {
            print("NOTE: No annotation exist.")
            return
        }
        
        map.selectAnnotation(targetAnnotation, animated: true)
    }
    
    
    private func createAnnotation(attraction: Attraction, attrIndex: Int) -> CustomerAnnotation {
        
        let annotation = CustomerAnnotation()
        annotation.coordinate = attraction.coordinate
        annotation.title = attraction.attrctionName
        annotation.tag = attrIndex + 1 // For present the number on the pin image
        
        return annotation
    }
    
    
    fileprivate func createAnnotationsAndGeodesics(cellContents: [CellContent]) -> ([CustomerAnnotation],[MKGeodesicPolyline]) {
        
        var tmpPtCoordonates = [CLLocationCoordinate2D]()
        var totalCoordinate = [[CLLocationCoordinate2D]]()
        var geodesics = [MKGeodesicPolyline]()
        var annotations = [CustomerAnnotation]()
        var attrIndex = 0
        
        let filteredCellContents = filterSuperfluousDateCellContents(cellContents: cellContents)
        
        for cellContent in filteredCellContents {
            
            if let content = cellContent as? ScheduleAndTrafficCellContent {
                
                let annotation = createAnnotation(attraction: content.attraction, attrIndex: attrIndex)
                
                tmpPtCoordonates.append(annotation.coordinate)
                annotations.append(annotation)
                
                attrIndex += 1
                
            } else if let content = cellContent as? DateCellContent {
                
                guard content != filteredCellContents.last else { continue }
                guard content.date != 1 else { continue }
                
                totalCoordinate.append(tmpPtCoordonates)
                tmpPtCoordonates.removeAll()
                
                attrIndex = 0
            }
        }
        
        totalCoordinate += [tmpPtCoordonates]
        
        for i in 0 ... totalCoordinate.count - 1 {
            let coordinates = totalCoordinate[i]
            let geodesic = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
            geodesic.subtitle = String(i)
            geodesics.append(geodesic)
        }
        
        return (annotations,geodesics)
    }
    
    
    private func producePinImg(text: String, annotationImg: UIImage) -> UIImage? {
        
        let imgSize = annotationImg.size
        
        let textFont = textfontSetting
        let textColor = UIColor.white
        let attributes = [ NSFontAttributeName: textFont,
                           NSForegroundColorAttributeName: textColor ]
        
        let myText = NSMutableAttributedString(string: text,
                                               attributes: attributes)
        let textSize = CGSize( width: myText.size().width,
                               height: myText.size().height )
        
        UIGraphicsBeginImageContext(imgSize)
        
        let ptX = ( (imgSize.width - textSize.width)/2 )
        let ptY = (imgSize.height * textPtYRatio)
        let point = CGPoint(x: ptX, y: ptY)
        
        annotationImg.draw(in: CGRect(origin: CGPoint.zero, size: imgSize))
        myText.draw(at: point)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

fileprivate class CustomerAnnotation: MKPointAnnotation {
    var tag: Int?
}
