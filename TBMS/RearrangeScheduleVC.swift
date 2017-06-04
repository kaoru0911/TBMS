//
//  RearrangeScheduleVC.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/26.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit

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
    let goSaveTripPageBtnTitle = "確認規劃"
    let saveTripBtnTitle = "儲存行程"
    
    var attractions: [Attraction]!
    var routesDetails: [LegsData]!
    var cellContentsArray = [CellContent]()
    let shareData = DataManager.shareDataManager
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    var travelDays : Int!
    var tmpTripData = [tripSpotData]()
    
    
    var expectedTravelMode = TravelMod.transit
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()//        let count = cellContentsArray.count - 1
        //        print((cellContentsArray[count] as! ScheduleAndTrafficCellContent).attraction)
        //        print((cellContentsArray[count] as! ScheduleAndTrafficCellContent).trafficTime)
        //        print((cellContentsArray[count] as! ScheduleAndTrafficCellContent).trafficInformation.duration)
        //        print((cellContentsArray[count] as! ScheduleAndTrafficCellContent).trafficInformation.distance)
        //        print((cellContentsArray[count] as! ScheduleAndTrafficCellContent).trafficInformation.steps[0].htmlInstructions)
        //        print((cellContentsArray[count] as! ScheduleAndTrafficCellContent).trafficInformation.steps)
        
        // Do any additional setup after loading the view.
        
        cellContentsArray = prepareCellsContents(attractions: attractions!, routesDetails: routesDetails)
        
        
        //實體化一個長壓的手勢物件, 當啟動時呼叫handleLongGesture這個func
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
                
                let cellContent = ScheduleAndTrafficCellContent(attraction: attractions[i-1], trafficInformation: nil)
                cellContent.type = CustomerCellType.lastAttactionCellType
                cellsContents.append(cellContent)
                
            } else {
                
                let cellContent = ScheduleAndTrafficCellContent(attraction: attractions[i-1], trafficInformation: routesDetails[i-1])
                cellsContents.append(cellContent)
            }
        }
        return cellsContents
    }
    
    //    //確認天數
    //    fileprivate func countTripDays(inputArray:[CellContent]) -> Int{
    //        var daysCounting = 0
    //        for obj in inputArray {
    //            if (obj is DateCellContent){
    //                daysCounting += 1
    //            }
    //        }
    //        return daysCounting
    //    }
    
    /// Produce the cellContent for next Page
    ///
    /// - Parameter intputArray: the cellContent Array including dateType and scheduleTrafficType cell, whitch we use them with different purples
    /// - Returns:
    ///     - The Array with dictionary type contents:
    ///         - the contens with key - "dailyScheduleSetting": CellContent with dateType.
    ///         - The contens with key - "scheduleArray": CellContent with dateType.
    
    
    fileprivate func seperateArrayByDate (intputArray:[CellContent]) -> [[String:Any]]
    {
        //-------測試用-------
        //        print("intputArray(seperateArrayByDate)=\(intputArray.count)")
        
        //-------------------
        
        //outputArray
        var seperateFinishArray = [[String:Any]]()
        //tmpObj
        var tmpDateCellContent = Int()
        var tmpArray = [ScheduleAndTrafficCellContent]()
        var tmpDic = [String:Any]()
        
        var isFirstObj = true
        
        for obj in intputArray {
            if isFirstObj {
                //如果是第一次, 將day的資訊丟到tmpdic
                tmpDateCellContent = 1
                isFirstObj = false
                //                print("FirstObj唷")
                
            } else if obj is DateCellContent {
                //                print("obj is DateCellContent唷")
                //如果是天數type, 將之前的tmpDic＆tmpArray彙整到一天頁面的物件, 並將tmpDic更新為現在這個obj
                tmpDic = [keyOfDateCell:tmpDateCellContent, keyOfScheduleAndTrafficCell:tmpArray]
                seperateFinishArray.append(tmpDic)
                
                tmpDateCellContent = (obj as! DateCellContent).date
                
            } else {
                //                print("obj is ScheduleAndTrafficCellContent唷")
                //是交通＆景點的type, 存到tmpArray中
                let tmpObj = obj as! ScheduleAndTrafficCellContent
                tmpArray += [tmpObj]
                
                if obj == intputArray.last {
                    //                    print("obj is last了唷")
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
    
    fileprivate func generateDetailRouteString (route:LegsData!) -> String {
        
        guard let routeData = route else {
            return "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        }
        return "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    }
    
    fileprivate func generateRouteTitleString (cellContent:ScheduleAndTrafficCellContent) -> String! {
        
        guard let travelTime = cellContent.trafficTime else { return "時間計算error唷" }
        guard travelTime != "routeCalculate error" else { return "時間計算error唷" }
        return "\(cellContent.travelMode!), \(travelTime)"
    }
}


// MARK: - Methods about packaging routes data and taking to the next page.
extension RearrangeScheduleVC {
    
    @IBAction func finishAndNextPage(_ sender: UIBarButtonItem) {
        
        let sb = UIStoryboard(name: nameOfFinalScheduleStoryBoard, bundle: nil)
        let trip = transferCellsContentToTripSpotDataType(cellContent: cellContentsArray)
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
                print("\(tmpAttractionData.spotName)")
                print("\(tmpAttractionData.trafficTitle)")
                print("\(tmpAttractionData.nDays)")
                print("\(tmpAttractionData.nTh)")
                print("\(tmpAttractionData.trafficToNextSpot)")
                
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
        case .dateCellType:
            return dayCellSize
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
            if indexPath.item == 0{
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
            cell.trafficInf.text = "\(cellContent.travelMode ?? ""), \(cellContent.trafficTime ?? "")"
            return cell
            
        case .lastAttactionCellType:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForLastAttractionCell, for: indexPath) as! LastAttractionCell
            let cellCotent = cellContentsArray[indexPath.item] as! ScheduleAndTrafficCellContent
            cell.viewPointName.text = cellCotent.viewPointName
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
        
        let dstIndex = (destinationIndexPath.item != 0 ? destinationIndexPath.item : 1)
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
    
    override func viewWillLayoutSubviews() {
        //        for _ in 0 ... spotData.count - 1 {
        //            cellSelectList += [false]
        //        }
    }
    
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        super.tableView(tableView, didSelectRowAt: indexPath)
    
    //        var selectStatus = cellSelectList[indexPath.row]
    //
    //        if selectStatus {
    //            selectStatus = false
    //        } else {
    //            selectStatus = true
    //        }
    //    }
}
