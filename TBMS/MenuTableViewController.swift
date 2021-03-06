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
        
        let color = UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = color
        self.navigationController?.navigationBar.barTintColor = color
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //xib的名稱
        let nib = UINib(nibName: "MenuCell", bundle: nil)
        
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        menuTableView.register(nib, forCellReuseIdentifier: "menuCell")
        
        cellData.append(("開始規劃" , UIImage(named: "kyoto2")!))
        
        cellData.append(("推薦行程" , UIImage(named: "paris3")!))
        
        cellData.append(("庫存行程" , UIImage(named: "Swizerland7")!))
        
        cellData.append(("庫存景點" , UIImage(named: "Swizerland8")!))
        
        if userDefault.string(forKey: "FBSDKAccessToken") != nil {
            
            sharedData.memberData?.account = userDefault.string(forKey: "FBSDKAccessToken")
            
            sharedData.memberData?.password = userDefault.string(forKey: "FBSDKAccessToken")
            
            serverCommunicate.useFBLogin()
        }
        
        self.view.backgroundColor = .black
        self.tableView.separatorStyle = .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
        self.segueLock = false
        sharedData.selectedProcess = .none
        sharedData.pocketSpot?.removeAll()
        sharedData.pocketTrips?.removeAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }

    
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
        
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
        
        guard segueLock == false else { return }
        
        performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
        
        segueLock = true
    }
    
    func connectFail() {
        
        let alert = generalModels.prepareCommentAlertVC(title: "伺服器連結異常",
                                                        message: "請先確認網路訊號, 或晚點再做測試唷",
                                                        cancelBtnTitle: "取消")
        present(alert, animated: true, completion: nil)
        
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
    }
    
    // MARK: - Table view data source
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotificationDidGet),
                                               name: serverCommunicate.downloadCoverImgNotifier,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NotificationDidGet),
                                               name: serverCommunicate.getPocketSpotNotifier,
                                               object: nil)
        
        
        
        switch choosen {
        case "開始規劃":
            
            sharedData.selectedProcess = .開始規劃
            sharedData.pocketSpot = [tripSpotData]()
            serverCommunicate.getPocketSpotFromServer()
            generalModels.customActivityIndicatory(self.view, startAnimate: true)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(NotificationDidGet),
                                                   name: serverCommunicate.getPocketSpotNotifier,
                                                   object: nil)
            
        case "推薦行程":
            
            sharedData.selectedProcess = .推薦行程
            
            if sharedData.sharedTrips?.count == 0 {
                
                sharedData.sharedTrips = [tripData]()
                serverCommunicate.getSharedTripFromServer()
                generalModels.customActivityIndicatory(self.view, startAnimate: true)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(NotificationDidGet),
                                                       name: serverCommunicate.downloadCoverImgNotifier,
                                                       object: nil)
                
                
            } else{
                performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
            }
            
            if sharedData.isLogin {
                guard let pocketSpot = sharedData.pocketSpot else {
                    return
                }
                
                if pocketSpot.isEmpty {
                    serverCommunicate.getPocketSpotFromServer()
                }
            }
            
        case "庫存行程":
            
            guard sharedData.isLogin else {
                showAlertMessage(title: "", message: "請先登入會員")
                return
            }
            
            sharedData.selectedProcess = .庫存行程
            
            if sharedData.pocketTrips?.count == 0 {
                
                sharedData.pocketTrips = [tripData]()
                serverCommunicate.getPocketTripFromServer()
                generalModels.customActivityIndicatory(self.view, startAnimate: true)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(NotificationDidGet),
                                                       name: serverCommunicate.downloadCoverImgNotifier,
                                                       object: nil)
                
            } else{
                
                performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
                
            }
            
        case "庫存景點":
            
            guard sharedData.isLogin else {
                showAlertMessage(title: "", message: "請先登入會員")
                return
            }
            
            sharedData.selectedProcess = .庫存景點
            
            if sharedData.pocketSpot?.count == 0 {
                
                serverCommunicate.getPocketSpotFromServer()
                generalModels.customActivityIndicatory(self.view, startAnimate: true)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(NotificationDidGet),
                                                       name: serverCommunicate.getPocketSpotNotifier,
                                                       object: nil)
                
            } else{
                
                performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
            }
            
        default:
            break
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(connectFail),
                                               name: serverCommunicate.connectServerFail,
                                               object: nil)
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

extension MenuTableViewController {
    
    @IBAction func functionName (_segue: UIStoryboardSegue) {}
    
    
    
}
