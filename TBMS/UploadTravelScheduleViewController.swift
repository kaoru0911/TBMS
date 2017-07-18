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
    let generalTools = GeneralToolModels()
    var sharedData = DataManager.shareDataManager
    
    let unwindSegueID = "unwindSegueToMenuVC"
    let toLoginSegueID = "UploadVCToLoginVCSegue"
    
    var getUploadTripNotifier = false
    var getUploadCoverImgNotifier = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let cornerRadius: CGFloat = 5
        changeTripCoverBtn.layer.cornerRadius = cornerRadius
        saveTripBtn.layer.cornerRadius = cornerRadius
        cancelAndBackToMenu.layer.cornerRadius = cornerRadius
        
        tripCoverImage.image = generalTools.chooseCoverImg(selectedCountry: sharedData.chooseCountry)
        
        // dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func changeCoverImgBtnPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "請選擇照片來源", message: nil, preferredStyle: .alert)
        
        let camera = UIAlertAction(title: "使用相機", style: .default) { (action:UIAlertAction) in
            self.launchImagePickerWithSourceType(type: .camera)
        }
        
        let photoLibray = UIAlertAction(title: "存取相簿", style: .default) { (action:UIAlertAction) in
            self.launchImagePickerWithSourceType(type: .photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(photoLibray)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadTripDataBtnPressed(_ sender: Any) {
        
        guard sharedData.isLogin else {
            
            let alert = generalTools.prepareUnloginAlertVC(title: "要儲存請先登入唷", message: nil, segueID: self.toLoginSegueID, targetVC: self)
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let tripName = tripNameTextField.text else {
            
            let alert = generalTools.prepareCommentAlertVC(title: "請先為本次行程命名唷",
                                                           message: nil,
                                                           cancelBtnTitle: "OK")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard tripName != "" else {
            
            let alert = generalTools.prepareCommentAlertVC(title: "請先為本次行程命名唷",
                                                           message: nil,
                                                           cancelBtnTitle: "OK")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard tripCoverImage.image != nil else {
            
            let alert = generalTools.prepareCommentAlertVC(title: "請為本次行程選擇封面",
                                                           message: nil,
                                                           cancelBtnTitle: "OK")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploadTripNotifierDidGet), name: server.uploadTripNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uploadCoverImgNotifierDidGet), name: server.uploadCoverImgNotifier, object: nil)
        
        generalTools.customActivityIndicatory(self.view, startAnimate: true)
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        
        let alert = generalTools.prepareCommentAlertVC(title: "你確定不儲存行程嗎？", message: "如按確定將直接回首頁", cancelBtnTitle: "取消")
        let ok = UIAlertAction(title: "確定", style: UIAlertActionStyle.destructive) { (ok) in
            self.backToTheMenuVC()
        }
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    func uploadTripNotifierDidGet() {
        
        print("DEBUG: Entered uploadTripNotifierDidGet")
        getUploadTripNotifier = true
        
        if getUploadCoverImgNotifier {
            backToTheMenuVC()
        }
    }
    
    func uploadCoverImgNotifierDidGet() {
        
        print("DEBUG: Entered uploadCoverImgNotifierDidGet")
        getUploadCoverImgNotifier = true
        
        if getUploadTripNotifier {
            backToTheMenuVC()
        }
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
    
    func backToTheMenuVC() {
        
        guard let vcs = self.navigationController?.viewControllers else {
            print("ERROR: navigation vc doesn't exist.")
            return
        }
        
        for vc in vcs {
            
            if vc is MenuTableViewController {
                self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        print("Note: UploadVC will deinit")
        generalTools.customActivityIndicatory(self.view, startAnimate: false)
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
}
