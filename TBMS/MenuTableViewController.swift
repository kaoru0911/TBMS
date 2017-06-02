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
        
//        cellData.append("開始規劃")
//        
//        cellData.append("推薦行程")
//        
//        cellData.append("庫存行程")
//        
//        cellData.append("庫存景點")
        
        //        serverCommunicate.uploadPocketSpotToServer(spotName: "清水寺")
        //        serverCommunicate.uploadPocketTripToServer(tripData: (sharedData.pocketTrips?[0])!)
        //        serverCommunicate.uploadSharedTripToServer(tripData: (sharedData.sharedTrips?[0])!)
        //        serverCommunicate.deletePocketSpotFromServer(spotName: "清水寺")
//        serverCommunicate.deletePocketTripFromServer(tripName: "香港三日遊")
        //        serverCommunicate.createAccount()
        //        serverCommunicate.userLogin()
                serverCommunicate.getPocketSpotFromServer()
                serverCommunicate.getPocketTripFromServer()
        //        serverCommunicate.userInfoUpdate()
                serverCommunicate.getSharedTripFromServer()
        //        serverCommunicate.uploadTripCoverImgToServer(tripData: (sharedData.pocketTrips?[0])!, Req: "uploadPocketTripCover")
        //        serverCommunicate.uploadTripCoverImgToServer(tripData: (sharedData.pocketTrips?[0])!, Req: "uploadSharedTripCover")

        
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
        performSegue(withIdentifier: "CountrySelectTableViewController", sender: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let nextPage = segue.destination as! CountrySelectTableViewController
        nextPage.selectedProcess = choosen
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
