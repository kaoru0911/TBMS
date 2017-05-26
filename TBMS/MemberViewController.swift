//
//  MemberViewController.swift
//  TBMS
//
//  Created by Ryder Tsai on 2017/5/26.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var changePersonalPhotoBtn: UIButton!
    @IBOutlet weak var personalImage: UIImageView!
    
    var imagePickerController = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        changePersonalPhotoBtn.layer.cornerRadius = 5.0
        
         imagePickerController.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
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

    
    @IBAction func changePersonalPhotoBtn(_ sender: Any) {
        
        let alert = UIAlertController(title: "選擇照片", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "使用相機", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "存取相簿", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "警告", message: "無法使用", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary() {
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
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
