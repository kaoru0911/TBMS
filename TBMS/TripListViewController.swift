//
//  TripListViewController.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/12.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class TripListViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{

    var selectedCountry: String!
    var selectedProcess: String!
    var tripArray = [tripData]()
    var sharedData = DataManager.shareDataManager
    var tripFilter: TripFilter!
    var selectCell: TripListTableViewCell!
    var serverCommunicate:ServerConnector = ServerConnector()
    
    @IBOutlet weak var tripListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("第三面囉")
        // Do any additional setup after loading the view.
        
        //xib的名稱
        let nib = UINib(nibName: "TripListCell", bundle: nil)
        
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        tripListTableView.register(nib, forCellReuseIdentifier: "tripListCell")
        
        tripFilter = TripFilter()
        
        tripArray = prepareTripArray(country: selectedCountry, rootSelect: selectedProcess)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "getTripSpotNotifier"), object: nil)
        
//        tripListTableView.delegate = self
//        tripListTableView.dataSource = self
        
//        tripArray.append(("東京遊", "四天三夜" , UIImage(named: "tokyo2")!))
//        tripArray.append(("巴黎遊", "七天六夜", UIImage(named: "paris4")!))
//        tripArray.append(("瑞士遊", "八天七夜", UIImage(named: "Swizerland3")!))
//        tripArray.append(("台北遊", "兩天一夜", UIImage(named: "taipei2")!))
//        tripArray.append(("東京遊", "四天三夜" , UIImage(named: "tokyo4")!))
//        tripArray.append(("巴黎遊", "七天六夜", UIImage(named: "Paris")!))
//        tripArray.append(("瑞士遊", "八天七夜", UIImage(named: "Swizerland")!))
//        tripArray.append(("台北遊", "兩天一夜", UIImage(named: "Taipei")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tripListTableView.dequeueReusableCell(withIdentifier: "tripListCell", for: indexPath) as! TripListTableViewCell;
        
        cell.tripTitle.text = tripArray[indexPath.row].tripName
        cell.tripSubTitle.text = "旅行天數：" + String(describing: tripArray[indexPath.row].days!) + "天"
        cell.tripCoverImg.image = tripArray[indexPath.row].coverImg
        
        cell.cellTripData = tripArray[indexPath.row]
        
        cell.tripTitle.shadowColor = UIColor.white
        cell.tripSubTitle.shadowColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectCell = tableView.cellForRow(at: indexPath) as! TripListTableViewCell
        
        // 清空資料重新下載
        sharedData.tempTripData = tripData()
        
        serverCommunicate.getTripSpotFromServer(selectTrip: selectCell.cellTripData, req: serverCommunicate.DOWNLOAD_POCKETTRIPSPOT_REQ)
    }
    
    func NotificationDidGet() {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vcArray = produceVCArray(myStoryBoard: sb, cellContents: sharedData.tempTripData)
        //設定scrollView
        let scrollVCProductor = ProduceScrollViewWithVCArray(vcArrayInput: vcArray)
        scrollVCProductor.pageControlDotExist = true
        scrollVCProductor.currentPageIndicatorTintColorSetting = UIColor.black
        scrollVCProductor.otherPageIndicatorTintColorSetting = UIColor.lightGray
        //輸出scrollView
        let scrollView = scrollVCProductor.pagingScrollingVC
        scrollView?.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        //        let nextPageBtn = UIBarButtonItem(title: goSaveTripPageBtnTitle, style: .plain, target: self, action: #selector(finishScheduleScrollViewAndGoNextPage))
        //        scrollView?.navigationItem.rightBarButtonItem = nextPageBtn
        
        self.navigationController?.pushViewController(scrollView!, animated: true)
    }
    
    
    func produceVCArray (myStoryBoard: UIStoryboard, cellContents:tripData!) -> [UIViewController] {
        
        var tmpVCArray = [ScheduleTableViewController]()
        guard let cellContents = cellContents else {
            print("沒有spot唷")
            return tmpVCArray
        }
        let travelDays = countTotalTripDays(spot: cellContents.spots)
        
        
        for i in 0...travelDays - 1 {
            
            let tmpVC = myStoryBoard.instantiateViewController(withIdentifier: "dailyRouteVC") as! ScheduleTableViewController
            tmpVC.data = cellContents
            tmpVC.nDaySchedule = i + 1
            
            tmpVCArray += [tmpVC]
            print("tmpVCArray=\(tmpVCArray.count)")
        }
        return tmpVCArray
    }
    
    func countTotalTripDays (spot:[tripSpotData]) -> Int {
        
        let days = (spot.max{$0.0.nDays < $0.1.nDays})?.nDays
        
        guard let travelDays = days else { return 0 }
        
        return travelDays
    }
    
    func finishScheduleScrollViewAndGoNextPage(tripDays:Int) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "UploadTripScheduleVC") as! UploadTravelScheduleViewController
        vc.travelDays = tripDays
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func prepareTripArray(country:String, rootSelect:String) -> [tripData] {
        
        var filtData = [tripData]()
//        var returnData = [(String , String, UIImage)]()
        
        switch rootSelect {
            case "推薦行程":
                filtData = tripFilter.filtByTripCountry(country: country, tripArray: sharedData.sharedTrips!)
            case "庫存行程":
                filtData = tripFilter.filtByTripCountry(country: country, tripArray: sharedData.pocketTrips!)
            default:
                break
        }
        
        return filtData
    }

}
