//
//  MemberViewController.swift
//  TBMS
//
//  Created by Ryder Tsai on 2017/5/26.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    

    @IBOutlet weak var changePersonalphotoBtn: UIButton!
    @IBOutlet weak var personalImage: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
            personalImage.image = UIImage(named: "UserPhotoDefault")
            changePersonalphotoBtn.layer.cornerRadius = 5.0
        
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
    
    @IBAction func changePersonalPhotoBtnPressed(_ sender: Any) {

    
        
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

   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imagePick = info[UIImagePickerControllerOriginalImage] as! UIImage
        personalImage.image = imagePick
        self.dismiss(animated: true, completion: nil)
    }
    
    //按下cancel的處理
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
