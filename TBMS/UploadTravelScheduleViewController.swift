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
    
    @IBOutlet weak var saveTripBtn: UIButton!
    @IBOutlet weak var changeTripCoverBtn: UIButton!
    @IBOutlet weak var cancelAndBackToMenu: UIButton!
    
    var trip = tripData()
    var travelDays: Int!
    var travelCountry: String!
    var attractionsAndRoute: [tripSpotData]!
    //    var spots: [tripSpotData]!
    var sharedData = DataManager.shareDataManager
    
    let unwindSegueID = "unwindSegueToMenuVC"
    var unwindSeguePassCheck = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let cornerRadius: CGFloat = 5
        changeTripCoverBtn.layer.cornerRadius = cornerRadius
        saveTripBtn.layer.cornerRadius = cornerRadius
        cancelAndBackToMenu.layer.cornerRadius = cornerRadius
        
        // dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        
        return unwindSeguePassCheck
    }
    
    @IBAction func changeCoverImgBtnPressed(_ sender: Any) {
        
        //        let imagePicker = UIImagePickerController()
        //        imagePicker.allowsEditing = false
        //        imagePicker.sourceType = .photoLibrary
        //        imagePicker.delegate = self
        //
        //        present(imagePicker, animated: true, completion: nil)
        
        let alert = UIAlertController(title: "請選擇照片來源", message: nil, preferredStyle: .alert)
        let camera = UIAlertAction(title: "使用相機", style: .default) { (action:UIAlertAction) in
            //self.openCamera()
            self.launchImagePickerWithSourceType(type: .camera)
        }
        let photoLibray = UIAlertAction(title: "存取相簿", style: .default) { (action:UIAlertAction) in
            //self.openPhotoLibrary()
            self.launchImagePickerWithSourceType(type: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(photoLibray)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadTripDataBtnPressed(_ sender: Any) {
        
        guard let tripName = tripNameTextField.text else {
            let alert = UIAlertController(title: "請記得為本次行程命名唷", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確認", style: .cancel, handler: nil)
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard tripCoverImage.image != nil else {
            let alert = UIAlertController(title: "請為本次行程選擇封面", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確認", style: .cancel, handler: nil)
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard sharedData.memberData != nil else {
            let alert = UIAlertController(title: "你還沒登入唷！", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確認", style: .cancel, handler: nil)
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        unwindSeguePassCheck = true
        
        trip.tripName = tripName
        trip.days = travelDays!
        trip.spots = sharedData.tmpSpotDatas
        trip.country = sharedData.chooseCountry
        trip.coverImg = tripCoverImage.image
        
        // 將行程名稱放入每個景點的資料裡面
        for i in 0 ..< trip.spots.count {
            trip.spots[i].belongTripName = tripName
        }
        
        let server = ServerConnector()
        
        server.uploadPocketTripToServer(tripData: trip)
        
        if shareTripOption.isOn {
            server.uploadSharedTripToServer(tripData: trip)
        }
        
        //        performSegue(withIdentifier: unwindSegueID, sender: nil)
    }
    
    func launchImagePickerWithSourceType(type:UIImagePickerControllerSourceType) {
        // Check if source type is available first
        if(UIImagePickerController.isSourceTypeAvailable(type) == false) {
            print("InValid Source Type")
            return
        }
        // Prepare picker
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = type
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imagePick = info[UIImagePickerControllerOriginalImage] as! UIImage
        tripCoverImage.image = imagePick
        self.dismiss(animated: true, completion: nil)
    }
    
    //按下cancel的處理
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // For pressing return on the keyboard to dismiss keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
