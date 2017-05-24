//
//  TripListViewController.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/12.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class TripListViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{

    var tripData = [(String , String, UIImage)]()
    
    @IBOutlet weak var tripListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //xib的名稱
        let nib = UINib(nibName: "TripListCell", bundle: nil)
        
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        tripListTableView.register(nib, forCellReuseIdentifier: "tripListCell")
        
//        tripListTableView.delegate = self
//        
//        tripListTableView.dataSource = self
        
        tripData.append(("東京遊", "四天三夜" , UIImage(named: "Kyoto")!))
        
        tripData.append(("巴黎遊", "七天六夜", UIImage(named: "Paris")!))
        
        tripData.append(("瑞士遊", "八天七夜", UIImage(named: "Swizerland")!))
        
        tripData.append(("台北遊", "兩天一夜", UIImage(named: "Taipei")!))
        
        tripData.append(("東京遊", "四天三夜" , UIImage(named: "Kyoto")!))
        
        tripData.append(("巴黎遊", "七天六夜", UIImage(named: "Paris")!))
        
        tripData.append(("瑞士遊", "八天七夜", UIImage(named: "Swizerland")!))
        
        tripData.append(("台北遊", "兩天一夜", UIImage(named: "Taipei")!))
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
        return tripData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tripListTableView.dequeueReusableCell(withIdentifier: "tripListCell", for: indexPath) as! TripListTableViewCell;
        
        cell.tripTitle.text = tripData[indexPath.row].0
        cell.tripSubTitle.text = tripData[indexPath.row].1
        cell.tripCoverImg.image = tripData[indexPath.row].2
        
        return cell
        
    }


}
