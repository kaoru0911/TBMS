//
//  UploadTravelScheduleViewController.swift
//  TBMS
//
//  Created by 倪僑德 on 2017/6/1.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit

class UploadTravelScheduleViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var tripCoverImage: UIImageView!
    @IBOutlet weak var shareTripOption: UISwitch!
    
    var trip = tripData()
    var travelDays: Int!
    var travelCountry: String!
    var attractionsAndRoute: [tripSpotData]!
//    var spots: [tripSpotData]!
    var sharedData = DataManager.shareDataManager
    
    let unwindSegueID = "unwindSegueToMenuVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeCoverImgBtnPressed(_ sender: Any) {
    
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadTripDataBtnPressed(_ sender: Any) {
        
        guard let tripName = tripNameTextField.text else {
            print("沒有name唷")
            return
        }
        
        guard tripCoverImage.image != nil else {
            print("沒有圖")
            /// show alert
            return
        }
        
        guard sharedData.memberData != nil else {
            print("沒有登入唷")
            /// show alert
                return
        }
        
        trip.tripName = tripName
        trip.days = travelDays!
        trip.spots = sharedData.tmpSpotDatas
        trip.country = sharedData.chooseCountry
        
        // 將行程名稱放入每個景點的資料裡面
        for i in 0..<trip.spots.count {
            trip.spots[i].belongTripName = tripName
        }
        
        let server = ServerConnector()
        
        server.uploadPocketTripToServer(tripData: trip)
        
        if shareTripOption.isOn {
            server.uploadSharedTripToServer(tripData: trip)
        }
        
        performSegue(withIdentifier: unwindSegueID, sender: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as! UIImage! else {
            print("image = nil")
            return
        }
        
        tripCoverImage.image = image
        trip.coverImg = image
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
//    func setNthValueToSpotData(tripName: String, tripDays: Int, spotDatas: [tripSpotData]) -> [tripSpotData] {
    
//        for spotData in spotDatas {
//            
//            spotData.belongTripName = tripName
//            spotData.nDays = tripName
//        }
//        
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
