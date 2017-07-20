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
    var selectedProcess: SelectedProcess!
    
    var sharedData = DataManager.shareDataManager
    var serverCommunicate:ServerConnector = ServerConnector()
    let generalModels = GeneralToolModels()
    
    var tripArray = [tripData]()
    var tripFilter: TripFilter!
    var selectCell: TripListTableViewCell!
    
    var didDeleteTrip = false
    
    @IBOutlet weak var tripListTableView: UITableView!
    
    // MARK:
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
        
        tripFilter = TripFilter()
        tripArray = prepareTripArray(country: selectedCountry,
                                     rootSelect: sharedData.selectedProcess.rawValue)
        
        if sharedData.selectedProcess == .庫存行程 {
            self.navigationItem.leftBarButtonItem = prepareConditionalLeftBarButton()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func saveTrip(tirp:tripData) {
        
        sharedData.tempTripData?.ownerUser = sharedData.memberData?.account
        
        generalModels.customActivityIndicatory(self.view, startAnimate: true)
        serverCommunicate.uploadPocketTripToServer(tripData: sharedData.tempTripData!)
        
        sharedData.pocketTrips = [tripData]()
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
            tmpVC.selectedProcess = sharedData.selectedProcess.rawValue
            
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
    
    func prepareTripArray(country:String, rootSelect:String) -> [tripData] {
        
        var filtData = [tripData]()
        
        switch sharedData.selectedProcess {
        case .推薦行程:
            filtData = tripFilter.filtByTripCountry(country: country, tripArray: sharedData.sharedTrips!)
        case .庫存行程:
            filtData = tripFilter.filtByTripCountry(country: country, tripArray: sharedData.pocketTrips!)
        default:
            break
        }
        return filtData
    }

    
    func instantiateNextVCAndPushIt(tripDays:Int) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "UploadTripScheduleVC") as! UploadTravelScheduleViewController
        vc.travelDays = tripDays
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func prepareConditionalLeftBarButton() -> UIBarButtonItem {
        
        let btn = UIBarButtonItem(title: "回\(sharedData.selectedProcess.rawValue)", style: .done, target: self, action: #selector(conditionalGoBeckProcess))
        return btn
    }
    
    func conditionalGoBeckProcess() {
        
        if didDeleteTrip {
            sharedData.pocketTrips?.removeAll()
            serverCommunicate.getPocketTripFromServer()
            NotificationCenter.default.addObserver(self, selector: #selector(pocketTripNotifierDidGet), name: serverCommunicate.downloadCoverImgNotifier, object: nil)
            generalModels.customActivityIndicatory(self.view, startAnimate: true)
            
        } else {
            
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    // MARK: - Functions about getting notifiers.
    func connectFail() {
        
        let alert = generalModels.prepareCommentAlertVC(title: "伺服器連結異常",
                                                        message: "請先確認網路訊號, 或晚點再做測試唷",
                                                        cancelBtnTitle: "取消")
        present(alert, animated: true, completion: nil)
        
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
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
        let alert = generalModels.prepareCommentAlertVC(title: "Success", message: "儲存完成")
        present(alert, animated: true, completion: nil)
    }
    
    func pocketTripNotifierDidGet() {
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Functions about TableView protocol
extension TripListViewController {
    
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
            
            cell.imageView?.contentMode = .scaleAspectFill
            
            serverCommunicate.deletePocketTripFromServer(tripName: tripName, completion: { () in
                
                self.didDeleteTrip = true
                self.tripArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tripArray counting = \(tripArray.count)")
        return tripArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tripListTableView.dequeueReusableCell(withIdentifier: "tripListCell", for: indexPath) as! TripListTableViewCell;
        
        cell.tripCoverImg.image = tripArray[indexPath.row].coverImg
        cell.tripCoverImg.layer.masksToBounds = true
        
        cell.cellTripData = tripArray[indexPath.row]
        
        cell.tripTitle.text = tripArray[indexPath.row].tripName
        cell.tripTitle.shadowColor = UIColor.white
        cell.tripTitle.shadowOffset = CGSize(width: 2, height: 2)
        
        cell.tripSubTitle.text = "旅行天數：" + String(describing: tripArray[indexPath.row].days!) + "天"
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
            
            generalModels.printCellTripDataDetails(tripData: selectCell.cellTripData)
            
        case .推薦行程:
            
            serverCommunicate.getTripSpotFromServer(selectTrip: selectCell.cellTripData,
                                                    req: serverCommunicate.DOWNLOAD_SHAREDTRIPSPOT_REQ)
            
            generalModels.printCellTripDataDetails(tripData: selectCell.cellTripData)
            
        default:
            print("ERROR: Nothing have to do. The selected process is \(sharedData.selectedProcess.rawValue)")
            break
        }
        
        generalModels.customActivityIndicatory(self.view, startAnimate: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if sharedData.selectedProcess == .庫存行程 {
            return true
        } else {
            return false
        }
    }
}
