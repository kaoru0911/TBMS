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
    
    var sharedData = DataManager.shareDataManager
    var serverCommunicate:ServerConnector = ServerConnector()
    let generalModels = GeneralToolModels()
    
    var tripArray = [tripData]()
    var tripFilter: TripFilter!
    var selectCell: TripListTableViewCell!
    
    var didDeleteTrip = false
    
    
    @IBOutlet weak var tripListTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //print("第三面囉")
        // Do any additional setup after loading the view.
        
        //xib的名稱
        let nib = UINib(nibName: "TripListCell", bundle: nil)
        
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        tripListTableView.register(nib, forCellReuseIdentifier: "tripListCell")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tripSpotNotificationDidGet),
                                               name: serverCommunicate.getTripSpotNotifier,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tripUploadNotificationDidGet),
                                               name: serverCommunicate.uploadTripNotifier,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(connectFail),
                                               name: serverCommunicate.connectServerFail,
                                               object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tripFilter = TripFilter()
        tripArray = prepareTripArray(country: selectedCountry, rootSelect: sharedData.selectedProcess.rawValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        serverCommunicate.getPocketTripFromServer()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tripArray counting = \(tripArray.count)")
        return tripArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tripListTableView.dequeueReusableCell(withIdentifier: "tripListCell", for: indexPath) as! TripListTableViewCell;
        
        cell.tripTitle.text = tripArray[indexPath.row].tripName
        cell.tripSubTitle.text = "旅行天數：" + String(describing: tripArray[indexPath.row].days!) + "天"
        cell.tripCoverImg.image = tripArray[indexPath.row].coverImg
        
        cell.cellTripData = tripArray[indexPath.row]
        
        cell.tripTitle.shadowColor = UIColor.white
        cell.tripTitle.shadowOffset = CGSize(width: 2, height: 2)
        cell.tripSubTitle.shadowColor = UIColor.white
        cell.tripSubTitle.shadowOffset = CGSize(width: 2, height: 2)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectCell = tableView.cellForRow(at: indexPath) as! TripListTableViewCell
        
        // 清空資料重新下載
        sharedData.tempTripData = tripData()
        
        switch sharedData.selectedProcess {
            
        case .庫存行程:
            
            selectCell.cellTripData.ownerUser = sharedData.memberData?.account
            serverCommunicate.getTripSpotFromServer(selectTrip: selectCell.cellTripData,
                                                    req: serverCommunicate.DOWNLOAD_POCKETTRIPSPOT_REQ)
            
            cellTripDataTest(tripData: selectCell.cellTripData)
            
        case .推薦行程:
            
            serverCommunicate.getTripSpotFromServer(selectTrip: selectCell.cellTripData,
                                                    req: serverCommunicate.DOWNLOAD_SHAREDTRIPSPOT_REQ)
            
            cellTripDataTest(tripData: selectCell.cellTripData)
            
        default:
            print("ERROR: Nothing have to do. The selected process is \(sharedData.selectedProcess.rawValue)")
            break
        }
        
        generalModels.customActivityIndicatory(self.view, startAnimate: true)
    }
    
    func cellTripDataTest(tripData: tripData) {
        
        print("TRIPLISTTEST: \(tripData.ownerUser ?? "nothing exist")!!!!")
        print("TRIPLISTTEST: \(tripData.country ?? "nothing exist")!!!!")
        print("TRIPLISTTEST: \(tripData.tripName ?? "nothing exist")!!!!")
        print("TRIPLISTTEST: \(tripData.days ?? 0)!!!!")
    }
    
    func tripSpotNotificationDidGet() {
        
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
        
        if sharedData.selectedProcess == .推薦行程 && sharedData.isLogin{
            let nextPageBtn = UIBarButtonItem(title: "儲存行程", style: .plain, target: self, action: #selector(saveTrip))
            scrollView?.navigationItem.rightBarButtonItem = nextPageBtn
        }
        
        // 關閉loading view
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
        
        self.navigationController?.pushViewController(scrollView!, animated: true)
    }
    
    func tripUploadNotificationDidGet() {
        
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
        showAlertMessage(title: "Success", message: "儲存完成")
    }
    
    func saveTrip(tirp:tripData) {
        
        sharedData.tempTripData?.ownerUser = sharedData.memberData?.account
        
        generalModels.customActivityIndicatory(self.view, startAnimate: true)
        serverCommunicate.uploadPocketTripToServer(tripData: sharedData.tempTripData!)
        
        sharedData.pocketTrips = [tripData]()
    }
    
    func showAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert,animated: true,completion: nil)
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
            tmpVC.selectedProcess = selectedProcess
            
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
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
}

extension TripListViewController {
    
    func connectFail() {
        
        let alert = generalModels.prepareCommentAlertVC(title: "伺服器連結異常",
                                                        message: "請先確認網路訊號, 或晚點再做測試唷",
                                                        cancelBtnTitle: "取消")
        present(alert, animated: true, completion: nil)
        
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let cell = tableView.cellForRow(at: indexPath) as? TripListTableViewCell else {
                print("ERROR: Cell type error, It's not a TripListTableViewCell")
                return
            }
            
            guard let tripName = cell.tripTitle.text else {
                print("ERROR: TripName doesn't exist.")
                return
            }
            
            serverCommunicate.deletePocketTripFromServer(tripName: tripName, completion: { () in
                
                self.didDeleteTrip = true
                self.tripArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
    }
}
