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
    var filter:TripFilter = TripFilter()
    var filtArray = [tripData]()
    
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "getPocketTripNotifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "getSharedTripNotifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationDidGet), name: NSNotification.Name(rawValue: "getPocketSpotNotifier"), object: nil)
        
        
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
        
        cell.menuCellImage.image = cellData[indexPath.row].1
        
        //cell.menuCellName.textColor = UIColor.white
        
        cell.menuCellName.shadowOffset = CGSize(width: 2, height: 2)
        
        cell.menuCellName.shadowColor = UIColor.white
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        choosen = cellData[indexPath.row].0
        
        switch choosen {
            case "開始規劃":
                if sharedData.pocketSpot?.count == 0 {
                    serverCommunicate.getPocketSpotFromServer()
                } else{
                    performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
                }
                
            case "推薦行程":
                if sharedData.sharedTrips?.count == 0 {
                    serverCommunicate.getSharedTripFromServer()
                } else{
                    performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
                }
                
            case "庫存行程":
                if !sharedData.isLogin {
                    showAlertMessage(title: "", message: "請先登入會員")
                    return
                }
                
                if sharedData.pocketTrips?.count == 0 {
                    serverCommunicate.getPocketTripFromServer()
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
                } else{
                    performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
                }
                
            default:
                break
        }
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
        performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
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
