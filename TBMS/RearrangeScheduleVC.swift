//
//  RearrangeScheduleVC.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/26.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit

class RearrangeScheduleVC: UIViewController, UIGestureRecognizerDelegate {
    
    // key setting
    let keyOfDateCell = "dailyScheduleSetting"
    let keyOfScheduleAndTrafficCell = "scheduleArray"
    let nameOfFinalScheduleStoryBoard = "FinalSchedule"
    let nameOfFinalScheduleVC = "FinalScheduleVC"
    let reuseIdForDateTypeCell = "DateCell"
    let reuseIdForscheduleAndTrafficCell = "scheduleAndTrafficCell"
    let currentPageDotTintColor = UIColor.black
    let otherPageDotTintColor = UIColor.lightGray
    
    var attractions : [Attraction]!
    var totalTrafficDetail : [LegsData]!
    var cellContentArray = [CellContent]()
    
    var expectedTravelMode = TravelMod.transit
    
    @IBOutlet weak var travelPathWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cellContentArray = prepareCellsContents(attractions: attractions, totalTrafficDetail: totalTrafficDetail)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareCellsContents (attractions:[Attraction], totalTrafficDetail:[LegsData]) -> [CellContent] {
        
        var cellsContents = [CellContent]()
        
        for i in 0...attractions.count {
            
            if i == 0 {
                let cellContent = DateCellContent(dateValue: 1)
                cellsContents.append(cellContent)
                
            } else if i == attractions.count {
                let cellContent = ScheduleAndTrafficCellContent(attraction: attractions[i])
                cellsContents.append(cellContent)
                
            } else {
                let cellContent = ScheduleAndTrafficCellContent(attraction: attractions[i], trafficInformation: totalTrafficDetail[i])
                
                if expectedTravelMode == .transit {
                    
                    cellContent.travelMode = TravelMod.walking.rawValue
                    for step in cellContent.trafficInformation.steps {
                        if step.travelMode == "TRANSIT" {
                            cellContent.travelMode = TravelMod.transit.rawValue
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
    
    @IBAction func finishAndNextPage(_ sender: UIBarButtonItem) {
        var tmpVCArray = [UIViewController]()
        
        //在尋訪Array的物件並切割天數func的次數
        let nextPageCellContentArray = seperateArrayByDate(intputArray: cellContentArray)
        
        //在於同圈迴圈中將ＶＣ作出來
        let sb = UIStoryboard(name: nameOfFinalScheduleStoryBoard, bundle: nil)
        let vcArray = produceVCArray(myStoryBoard: sb, dataArray: nextPageCellContentArray)
        
        //設定scrollView
        let scrollVCProductor = ProduceScrollViewWithVCArray(vcArrayInput: vcArray)
        scrollVCProductor.pageControlDotExist = true
        scrollVCProductor.currentPageIndicatorTintColorSetting = currentPageDotTintColor
        scrollVCProductor.otherPageIndicatorTintColorSetting = otherPageDotTintColor
        
        //輸出scrollView
        let scrollView = scrollVCProductor.pagingScrollingVC
        present(scrollView!, animated: true, completion: nil)
        
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
    func produceVCArray (myStoryBoard: UIStoryboard,dataArray:[[String:[AnyObject]]]) -> [UIViewController] {
        //將Array內資料套出, 將date用於設定相關資料, 將array用於匯入下一面
        var tmpVCArray = [UIViewController]()
        for vcContent in dataArray {
            // 實體化ＶＣ
            let tmpVC = myStoryBoard.instantiateViewController(withIdentifier: nameOfFinalScheduleVC) as! FinalScheduleVC
            // 將資料喂給ＶＣ
            tmpVC.contantDataStorage = vcContent
            // 將ＶＣ帶入array
            tmpVCArray += [tmpVC]
        }
        return tmpVCArray
    }
}



extension RearrangeScheduleVC : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellContentArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Check the cell is for prsenting Date or viewPoint and traffic information, then built it.
        switch cellContentArray[indexPath.item].type! {
        //for presenting Date
        case .dateCellType:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForDateTypeCell, for: indexPath) as! DateCell
            // if is the 1st day cell, show the adding days button
            if indexPath.item == 0{
                cell.addNewTripDayButton.isHidden = false
            }
            // setting the label text
            let cellContent = cellContentArray[indexPath.item] as! DateCellContent
            cell.dateLabel.text = cellContent.dateStringForLabel
            return cell
            
        //for presenting viewPoint and traffic information
        case .scheduleAndTrafficCellType:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForscheduleAndTrafficCell, for: indexPath) as! ScheduleAndTrafficCell
            // setting the label text
            let cellContent = cellContentArray[indexPath.item] as! ScheduleAndTrafficCellContent
            cell.viewPointName.text = cellContent.viewPointName
            cell.trafficInf.text = "\(cellContent.travelMode), \(cellContent.trafficTime)"
            //            if let viewPointDetail = cellContent. {
            //                cell.viewPointDetail.text = viewPointDetail
            //            }
            return cell
            
        //CellType unknown or Type wrong
//        default:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdForDateTypeCell, for: indexPath)
//            return cell
        }
    }
    
}
