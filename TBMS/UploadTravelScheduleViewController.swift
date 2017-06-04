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
    
    var sharedData = DataManager.shareDataManager
    
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
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadTripDataBtnPressed(_ sender: Any) {
        
        guard let tripName = tripNameTextField.text else {
            /// show alert
            return
        }
        
        guard let image = tripCoverImage.image else {
            /// show alert
            return
        }
        
        guard sharedData.memberData != nil else {
            /// show alert
                return
        }
        
        trip.tripName = tripName
        trip.coverImg = image

        trip.days = travelDays
        trip.spots = attractionsAndRoute
        trip.country = sharedData.chooseCountry
        
        let server = ServerConnector()
        server.uploadPocketTripToServer(tripData: trip)
        
        if shareTripOption.isOn {
            server.uploadSharedTripToServer(tripData: trip)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as! UIImage! else {
            print("image = nil")
            return
        }
        
        tripCoverImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
