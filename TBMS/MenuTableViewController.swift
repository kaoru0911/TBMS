//
//  MenuTableViewController.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/11.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    
    @IBOutlet weak var menuTableView: UITableView!
    
    //    var container: UIView = UIView()
    //    var loadingView: UIView = UIView()
    //    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    var choosen = ""
    
    var cellData = [(String , UIImage)]()
    //var cellData = String()
    var selectedPage : Int!
    var sharedData:DataManager = DataManager.shareDataManager
    var serverCommunicate:ServerConnector = ServerConnector()
    let generalModels = GeneralToolModels()
    var filter:TripFilter = TripFilter()
    var filtArray = [tripData]()
    var segueLock = false
    
    let userDefault = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //xib的名稱
        let nib = UINib(nibName: "MenuCell", bundle: nil)
        
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        menuTableView.register(nib, forCellReuseIdentifier: "menuCell")
        
        //menuTableView.delegate = self
        
        //menuTableView.dataSource = self
        
        cellData.append(("開始規劃" , UIImage(named: "kyoto2")!))
        
        cellData.append(("推薦行程" , UIImage(named: "paris3")!))
        
        cellData.append(("庫存行程" , UIImage(named: "Swizerland7")!))
        
        cellData.append(("庫存景點" , UIImage(named: "Swizerland8")!))
        
//        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "getPocketTripNotifier"), object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "getSharedTripNotifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "downloadCoverImgNotifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "getPocketSpotNotifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectFail), name: NSNotification.Name(rawValue: "connectServerFail"), object: nil)
        
        //        userDefault.set("FBTest", forKey: "FBSDKAccessToken")
        //        userDefault.set(nil, forKey: "FBSDKAccessToken")
        
        if userDefault.string(forKey: "FBSDKAccessToken") != nil {
            
            sharedData.memberData?.account = userDefault.string(forKey: "FBSDKAccessToken")
            
            sharedData.memberData?.password = userDefault.string(forKey: "FBSDKAccessToken")
            
            serverCommunicate.useFBLogin()
        }
        
        
        //        serverCommunicate.uploadPocketSpotToServer(spotName: "清水寺")
        //        serverCommunicate.uploadPocketTripToServer(tripData: (sharedData.pocketTrips?[0])!)
        //        serverCommunicate.uploadSharedTripToServer(tripData: (sharedData.sharedTrips?[0])!)
        //        serverCommunicate.deletePocketSpotFromServer(spotName: "清水寺")
        //        serverCommunicate.deletePocketTripFromServer(tripName: "香港三日遊")
        //        serverCommunicate.createAccount()
        //        serverCommunicate.userLogin()
        //                serverCommunicate.getPocketSpotFromServer()
        //                serverCommunicate.getPocketTripFromServer()
        //        serverCommunicate.userInfoUpdate()
        //                serverCommunicate.getSharedTripFromServer()
        //                serverCommunicate.uploadTripCoverImgToServer(tripData: (sharedData.pocketTrips?[0])!, Req: "uploadPocketTripCover")
        //        serverCommunicate.uploadTripCoverImgToServer(tripData: (sharedData.pocketTrips?[0])!, Req: "uploadSharedTripCover")
        
        //===========================
        //        let testTripData = tripData()
        //        testTripData.ownerUser = "create"
        //        testTripData.tripName = "日本五日遊"
        //
        //        serverCommunicate.getTripSpotFromServer(selectTrip: testTripData, req: serverCommunicate.DOWNLOAD_SHAREDTRIPSPOT_REQ)
        //===========================
        
        self.view.backgroundColor = .black
//        self.tableView.rowHeight = 175
        self.tableView.separatorStyle = .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 4
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell;
        
        cell.menuCellName.text = cellData[indexPath.row].0
        cell.menuCellName.textColor = .white
        cell.menuCellName.font = UIFont.boldSystemFont(ofSize: 30)
        
        cell.menuCellImage.image = cellData[indexPath.row].1
        cell.menuCellImage.alpha = 0.65
        cell.backgroundColor = .black
        
        cell.menuCellName.layer.shadowOpacity = 1
        cell.menuCellName.layer.shadowRadius = 3
        cell.menuCellName.layer.shadowOffset = CGSize(width: 0, height: 0)
//        cell.menuCellName.shadowColor = .black
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        choosen = cellData[indexPath.row].0
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch choosen {
        case "開始規劃":
            sharedData.pocketSpot = [tripSpotData]()
            serverCommunicate.getPocketSpotFromServer()
            customActivityIndicatory(self.view, startAnimate: true)
            
        case "推薦行程":
            if sharedData.sharedTrips?.count == 0 {
                
                sharedData.sharedTrips = [tripData]()
                serverCommunicate.getSharedTripFromServer()
                customActivityIndicatory(self.view, startAnimate: true)
            } else{
                performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
            }
            
        case "庫存行程":
            if !sharedData.isLogin {
                showAlertMessage(title: "", message: "請先登入會員")
                return
            }
            
            if sharedData.pocketTrips?.count == 0 {
                sharedData.pocketTrips = [tripData]()
                serverCommunicate.getPocketTripFromServer()
                customActivityIndicatory(self.view, startAnimate: true)
                
            } else{
                performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
            }
            
        case "庫存景點":
            if !sharedData.isLogin {
                showAlertMessage(title: "", message: "請先登入會員")
                return
            }
            
            if sharedData.pocketSpot?.count == 0 {
                
                serverCommunicate.getPocketSpotFromServer()
                
                // show loading view
                customActivityIndicatory(self.view, startAnimate: true)
            } else{
                performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
            }
            
        default:
            break
        }
    }
    
    //    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    //
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextPage = segue.destination as! CountrySelectTableViewController
        nextPage.selectedProcess = choosen
    }
    
    func showAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert,animated: true,completion: nil)
    }
    
    func NotificationDidGet() {
        
        customActivityIndicatory(self.view, startAnimate: false)
        
        guard segueLock == false else { return }
        
        performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
        
        segueLock = true
    }
    
    func connectFail() {
        
        let alert = generalModels.prepareCommentAlertVC(title: "伺服器連結異常",
                                                        message: "請先確認網路訊號, 或晚點再做測試唷",
                                                        cancelBtnTitle: "取消")
        present(alert, animated: true, completion: nil)
        
        customActivityIndicatory(self.view, startAnimate: false)
    }
    
    func customActivityIndicatory(_ viewContainer: UIView, startAnimate:Bool? = true) {
        
        // 做一個透明的view來裝
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
        // background的alpha跟view的alpha不同
        mainContainer.alpha = 0.5
        //================================
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        // 旋轉圈圈放在這個view上
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = viewContainer.center
        //        viewBackgroundLoading.backgroundColor = UIColor(red:0x7F, green:0x7F, blue:0x7F, alpha: 1)
        viewBackgroundLoading.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 1)
        //================================
        //        viewBackgroundLoading.alpha = 0.5
        //================================
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        // 創造旋轉圈圈
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }
        //        return activityIndicatorView
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
    
}

extension MenuTableViewController {
    
    @IBAction func functionName (_segue: UIStoryboardSegue) {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
        self.segueLock = false
    }
    
    override func viewWillLayoutSubviews() {
        let color = UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = color
        self.navigationController?.navigationBar.barTintColor = color
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let tabBarHeight = self.tabBarController?.tabBar.frame.height else {
            return 140
        }
        guard let navigationBarHeight = self.navigationController?.navigationBar.frame.height else {
            return 140
        }
        
        let totalHeight = tableView.frame.height - tabBarHeight - navigationBarHeight
        let height = totalHeight / 4
        
        return height
    }
}
