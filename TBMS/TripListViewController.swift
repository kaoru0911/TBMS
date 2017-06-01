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
    var tripArray = [(String , String, UIImage)]()
    var sharedData = DataManager.shareDataManager
    var tripFilter: TripFilter!
    
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
        
        cell.tripTitle.text = tripArray[indexPath.row].0
        cell.tripSubTitle.text = "旅行天數：" + tripArray[indexPath.row].1 + "天"
        cell.tripCoverImg.image = tripArray[indexPath.row].2
        
        cell.tripTitle.shadowColor = UIColor.white
        cell.tripSubTitle.shadowColor = UIColor.white
        
        return cell
    }
    
    func prepareTripArray(country:String, rootSelect:String) -> [(String , String, UIImage)] {
        
        var filtData = [tripData]()
        var returnData = [(String , String, UIImage)]()
        
        switch rootSelect {
            case "推薦行程":
                filtData = tripFilter.filtByTripCountry(country: country, tripArray: sharedData.sharedTrips!)
            case "庫存行程":
                filtData = tripFilter.filtByTripCountry(country: country, tripArray: sharedData.pocketTrips!)
            default:
                break
        }
        
        if filtData.count > 0 {
            
            for i in 0...filtData.count-1 {
                returnData.append((filtData[i].tripName!, String(describing: filtData[i].days!), filtData[i].coverImg!))
            }
        }        
        
        return returnData
    }

}
