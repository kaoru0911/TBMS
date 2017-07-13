//
//  CountrySelectTableViewController.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/12.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class CountrySelectTableViewController: UITableViewController, ContinentalViewDelegate {
    
    var selectedProcess: String!
    var selectedCountry: String!
    var continentalGroups: NSArray!
    var sectionInfoArray: NSMutableArray!
    var openSectionIndex = NSNotFound
    var sharedData = DataManager.shareDataManager
    
//    var choosen: String!
    var segueID : String!
    var nextViewController: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedProcess)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.sectionHeaderHeight = 60
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        continentalGroups = loadCountryInfo()
        
        let sectionHeaderNib: UINib = UINib(nibName: "ContinentalView", bundle: nil)
        
        self.tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "ContinentalViewId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true
        
        // 檢查sectionInfoArray是否已被建立，或數量是否正確
        if sectionInfoArray == nil || sectionInfoArray.count != self.numberOfSections(in: self.tableView){
            
            let infoArray: NSMutableArray = NSMutableArray()
            
            for group in continentalGroups {
                
                let sectionInfo: SectionInfo = SectionInfo()
                
                sectionInfo.continentalGroup = group as! ContinentalGroup
                
                sectionInfo.continentalView.isHeaderOpen = false
                
                infoArray.add(sectionInfo)
            }
            
            sectionInfoArray = infoArray
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.continentalGroups.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        
        let numOfCountries = sectionInfo.continentalGroup.countries.count
        
        if sectionInfo.continentalView.isHeaderOpen{
            return numOfCountries
        } else {
            return 0
        }
    }
    
    func loadCountryInfo() -> NSArray{
        
        var countryInfo:NSMutableArray
        
        // 將plist文件中的內容取出
        let fileUrl = Bundle.main.path(forResource: "CountryInfo", ofType: "plist")
        
        let continentalDicArray = NSArray(contentsOfFile: fileUrl!) as! [[String:Any]]
        
        countryInfo = NSMutableArray(capacity: continentalDicArray.count)
        
        
        for continentalDic in continentalDicArray {
            
            let continentalGroup: ContinentalGroup = ContinentalGroup()
            
            continentalGroup.name  = continentalDic["continentalName"] as! String
            
            let countryArrays: NSArray = continentalDic["countries"] as! NSArray
            
            let countries = NSMutableArray(capacity: countryArrays.count)
            
            for country in countryArrays {
                
                countries.add(country)
            }
            
            continentalGroup.countries = countries
            
            countryInfo.add(continentalGroup)
        }
        
        return countryInfo
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountrySelectTableViewCellId", for: indexPath) as! CountrySelectTableViewCell
        
        let continentalGroup = (sectionInfoArray[indexPath.section] as! SectionInfo).continentalGroup
        
        cell.countryName.text = continentalGroup.countries[indexPath.row] as? String
        
        cell.countryImg.image = UIImage(named: (continentalGroup.countries[indexPath.row] as? String)! + ".png")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeaderView: ContinentalView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ContinentalViewId") as! ContinentalView
        
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        
        sectionInfo.continentalView = sectionHeaderView
        
        sectionHeaderView.continentalName.text = sectionInfo.continentalGroup.name
        
        sectionHeaderView.section = section
        
        sectionHeaderView.delegate = self as ContinentalViewDelegate
        
        return sectionHeaderView
    }
    
    func ContinentalView(ContinentalView: ContinentalView, sectionOpened: Int) {
        
        let sectionInfo: SectionInfo = sectionInfoArray[sectionOpened] as! SectionInfo
        
        sectionInfo.continentalView.isHeaderOpen = true
        
        let countOfRowsToInsert = sectionInfo.continentalGroup.countries.count
        let indexPathsToInsert = NSMutableArray()
        
        // 儲存cell的插入路徑
        for i in 0..<countOfRowsToInsert {
            indexPathsToInsert.add(NSIndexPath(row: i, section: sectionOpened))
        }
        
        
        // 儲存cell的刪除路徑
        let indexPathsToDelete = NSMutableArray()
        let previousOpenSectionIndex = openSectionIndex
        
        if previousOpenSectionIndex != NSNotFound {
            
            let previousOpenSection: SectionInfo = sectionInfoArray[previousOpenSectionIndex] as! SectionInfo
            
            previousOpenSection.continentalView.isHeaderOpen = false
            
            previousOpenSection.continentalView.closureStateChange(userAction: false)
            
            let countOfRowsToDelete = previousOpenSection.continentalGroup.countries.count
            
            for i in 0..<countOfRowsToDelete {
                indexPathsToDelete.add(NSIndexPath(row: i, section: previousOpenSectionIndex))
            }
        }
        
        // 打開與關閉的動畫
        var insertAnimation: UITableViewRowAnimation
        var deleteAnimation: UITableViewRowAnimation
        
        if previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex {
            insertAnimation = UITableViewRowAnimation.top
            deleteAnimation = UITableViewRowAnimation.bottom
        }else{
            insertAnimation = UITableViewRowAnimation.bottom
            deleteAnimation = UITableViewRowAnimation.top
        }
        
        // 更新cell
        self.tableView.beginUpdates()
        
        self.tableView.deleteRows(at: indexPathsToDelete as! [IndexPath], with: deleteAnimation)
        
        self.tableView.insertRows(at: indexPathsToInsert as! [IndexPath], with: insertAnimation)
        
        openSectionIndex = sectionOpened
        
        self.tableView.endUpdates()
        
    }
    
    func ContinentalView(ContinentalView: ContinentalView, sectionClosed: Int) {
        
        //  儲存section路徑，並刪除裡面的row
        let sectionInfo: SectionInfo = sectionInfoArray[sectionClosed] as! SectionInfo
        
        sectionInfo.continentalView.isHeaderOpen = false
        
        let countOfRowToDelete = self.tableView.numberOfRows(inSection: sectionClosed)
        
        if countOfRowToDelete > 0 {
            
            let indexPathsToDelete = NSMutableArray()
            
            for i in 0..<countOfRowToDelete {
                indexPathsToDelete.add(NSIndexPath(row: i, section: sectionClosed))
            }
            
            self.tableView.deleteRows(at: indexPathsToDelete as! [IndexPath], with: UITableViewRowAnimation.top)
        }
        
        
        // 在表格关闭的时候，创建一个包含单元格索引路径的数组，接下来从表格中删除这些行
        
        openSectionIndex = NSNotFound
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch selectedProcess {
        case "開始規劃":
            self.segueID = "goAddPointVC"
        case "推薦行程":
            self.segueID = "goTripListViewController"
        case "庫存行程":
            self.segueID = "goTripListViewController"
        case "庫存景點":
            self.segueID = "goPocketSpotTVC"
        default:
            self.segueID = "goAddPointVC"
        }
        print(self.segueID)
        
        let selectCell = tableView.cellForRow(at: indexPath) as! CountrySelectTableViewCell
        
        selectedCountry = selectCell.countryName.text
        
        sharedData.chooseCountry = selectedCountry
        
        
        performSegue(withIdentifier: segueID, sender: nil)
        
        //畫面精進，讓點選後的灰色不會卡在選擇列上，灰色會閃一下就消失
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if(segue.identifier == "goAddPointVC") {
            
            let nextPage = segue.destination as! AddViewPointViewController
            nextPage.selectedCountry = selectedCountry
            
        } else if (segue.identifier == "goPocketSpotTVC") {
            
            let nextPage = segue.destination as! PocketSpotTVC
            
            nextPage.selectedCountry = selectedCountry
            
            nextPage.selectedProcess = selectedProcess
            
        } else if (segue.identifier == "goTripListViewController") {
            
            let nextPage = segue.destination as! TripListViewController
            
            nextPage.selectedProcess = selectedProcess
            
            nextPage.selectedCountry = selectedCountry
        }
    }
}



/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


