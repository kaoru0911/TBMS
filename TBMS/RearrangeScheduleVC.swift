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
    private let keyOfDateCell = "dailyScheduleSetting"
    private let keyOfScheduleAndTrafficCell = "scheduleArray"
    private let nameOfFinalScheduleStoryBoard = "FinalSchedule"
    private let nameOfFinalScheduleVC = "FinalScheduleVC"
    let reuseIdForDateTypeCell = "dateCell"
    let reuseIdForscheduleAndTrafficCell = "scheduleAndTrafficCell"
    let reuseIdForLastAttractionCell = "lastAttractionCell"
    private let currentPageDotTintColor = UIColor.black
    private let otherPageDotTintColor = UIColor.lightGray
    
    private let strTransitTravelMode = "TRANSIT"
    private let strWalkingTravelMode = "WALKING"
    private let strDrivingTravelMode = "DRIVING"
    
    var attractions : [Attraction]!
    var routesDetails : [LegsData]!
    var cellContentsArray = [CellContent]()
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    var expectedTravelMode = TravelMod.transit

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cellContentsArray = prepareCellsContents(attractions: attractions, routesDetails: routesDetails)
        //實體化一個長壓的手勢物件, 當啟動時呼叫handleLongGesture這個func
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(_:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func prepareCellsContents (attractions:[Attraction], routesDetails:[LegsData]) -> [CellContent] {
        
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
                
                if expectedTravelMode == .transit {
                    cellContent.travelMode = TravelMod.walking.rawValue
                    var i = 0
                    for step in cellContent.trafficInformation.steps {
                        //--------測試用--------
                        i += 1
                        print("i=\(i)")
                        //---------------------
                        if step.travelMode == strTransitTravelMode {
                            cellContent.travelMode = TravelMod.transit.rawValue
                            break
                            
                        } else if step.travelMode == strDrivingTravelMode {
                            cellContent.travelMode = TravelMod.driving.rawValue
                            break
                        }
                    }
                } else {
                    cellContent.travelMode = expectedTravelMode.rawValue
                }
                cellsContents.append(cellContent)
            }
        }
        return cellsContents
    }
    
    //    //確認天數
    //    private func countTripDays(inputArray:[CellContent]) -> Int{
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
    ///         - the contens with key - "dailyScheduleSetting" : CellContent with dateType.
    ///         - The contens with key - "scheduleArray" : CellContent with dateType.
    private func seperateArrayByDate (intputArray:[CellContent]) -> [[String:[AnyObject]]] {
        
        //tmpObj
        var tmpArray = [ScheduleAndTrafficCellContent]()
        var tmpDictionary = [String:[CellContent]]()
        var isFirstObj = true
        
        //outputArray
        var seperateFinishArray = [[String:[AnyObject]]]()
        
        for obj in intputArray {
            if obj is DateCellContent && isFirstObj {
                //如果是第一次, 將day的資訊丟到tmpdic
                tmpDictionary = [keyOfDateCell:[obj]]
                isFirstObj = false
                
            } else if obj is DateCellContent {
                //如果是天數type, 將之前的tmpDic＆tmpArray彙整到一天頁面的物件, 並將tmpDic更新為現在這個obj
                seperateFinishArray += [tmpDictionary,[keyOfScheduleAndTrafficCell:tmpArray]]
                
                tmpDictionary = [keyOfDateCell:[obj]]
                
            } else {
                //是交通＆景點的type, 存到tmpArray中
                let tmpObj = obj as! ScheduleAndTrafficCellContent
                tmpArray += [tmpObj]
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
    private func produceVCArray (myStoryBoard: UIStoryboard,dataArray:[[String:[AnyObject]]]) -> [UIViewController] {
        //將Array內資料套出, 將date用於設定相關資料, 將array用於匯入下一面
        var tmpVCArray = [UIViewController]()
        for vcContent in dataArray {
            
            let tmpVC = myStoryBoard.instantiateViewController(withIdentifier: nameOfFinalScheduleVC) as! FinalScheduleVC
            tmpVC.contantDataStorage = vcContent
            tmpVCArray += [tmpVC]
        }
        return tmpVCArray
    }
    
    func replaceCellContent () { // 當移動時觸發

        /* 情況：
            1. 移動天數cell :
                移動前 - 如果下一個cell 是traffic的 ：
                    Ｙ. 計算前一個與下一個的交通, 並變更前一個cellType
                    N. 不做動作
                移動後 - 如果前一個cell是traffic的:
                            Y.變更前一個CellType為Last
                            N.沒差
            2. 移動景點cell :
                移動前 - 前一個cell是Traffic:
                            Y. 如果下一個cell不是date, 重新計算前一個cell交通
                                如果下一個cell是Date, 將前一個cell設為last
                移動後 - 如果前一個cell不是date：
                            Y. 將cellType改為traffic並計算交通
                            N. 沒事
                        如果後一個cell不是date：
                            Y. 將自己cellType改為traffic並計算交通
                            N. 沒事
        */
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
    
    // Mark: IBAction func
    @IBAction func addDateCellBtnPressed(_ sender: UIButton) {
        
        let totalDays = cellContentsArray.filter({$0.type == CustomerCellType.dateCellType}).count
        let newDateCellContent = DateCellContent(dateValue: totalDays + 1)
        cellContentsArray.append(newDateCellContent)
        self.collectionView.reloadData()
    }
    
    @IBAction func finishAndNextPage(_ sender: UIBarButtonItem) {
        var tmpVCArray = [UIViewController]()
        
        //在尋訪Array的物件並切割天數func的次數
        let nextPagecellContentsArray = seperateArrayByDate(intputArray: cellContentsArray)
        
        //在於同圈迴圈中將ＶＣ作出來
        let sb = UIStoryboard(name: nameOfFinalScheduleStoryBoard, bundle: nil)
        let vcArray = produceVCArray(myStoryBoard: sb, dataArray: nextPagecellContentsArray)
        
        //設定scrollView
        let scrollVCProductor = ProduceScrollViewWithVCArray(vcArrayInput: vcArray)
        scrollVCProductor.pageControlDotExist = true
        scrollVCProductor.currentPageIndicatorTintColorSetting = currentPageDotTintColor
        scrollVCProductor.otherPageIndicatorTintColorSetting = otherPageDotTintColor
        
        //輸出scrollView
        let scrollView = scrollVCProductor.pagingScrollingVC
        present(scrollView!, animated: true, completion: nil)
    }
}



extension RearrangeScheduleVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(cellContentsArray.count)
        print("numberOfItemsInSection唷！！！！")
        return cellContentsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("sizeForItemAt唷＠＠＠＠＠")
        
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
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movedCellContent = cellContentsArray.remove(at: sourceIndexPath.item)
        cellContentsArray.insert(movedCellContent, at: destinationIndexPath.item)
    }
}
