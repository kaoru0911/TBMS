//
//  MemberViewController.swift
//  TBMS
//
//  Created by Ryder Tsai on 2017/5/26.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var changePersonalphotoBtn: UIButton!
    @IBOutlet weak var personalImage: UIImageView!
    
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var resetDataBtn: UIButton!
    var serverCommunicate: ServerConnector = ServerConnector()
    var sharedData = DataManager.shareDataManager

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
            personalImage.image = UIImage(named: "UserPhotoDefault")
            changePersonalphotoBtn.layer.cornerRadius = 5.0
            resetDataBtn.layer.cornerRadius = 5.0
            logoutBtn.layer.cornerRadius = 5.0
        
        usernameLabel.text = sharedData.memberData?.account
        passwordTextField.text =  sharedData.memberData?.password
        emailTextField.text = sharedData.memberData?.email
        
        // dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)

        
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
    
    func showAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert,animated: true,completion: nil)
    }
   
    // 重設資料按鈕
    @IBAction func resetDataBtn(_ sender: Any) {
        
        sharedData.memberData?.password = passwordTextField.text
        
        sharedData.memberData?.email = emailTextField.text
        
        serverCommunicate.userInfoUpdate()
    }
  
    // 登出按鈕
    @IBAction func LogoutBtn(_ sender: Any) {
        
        serverCommunicate.userLogout()
        
        showAlertMessage(title: "Success", message: "登出成功")
        
        // =============================================
        // 創造一個新個TabBarController與NavigationController，再放回appDelegate內取代原本的root
        // =============================================
        
        // TabBar
        let rootTabBarController = UITabBarController()
        
        // 注意！創造viewController的方式跟創造view的方式不同
        //            let rightTab = MemberViewController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rightTab = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        rightTab.title = "會員登入"
        
        let rightTabBarItem = UITabBarItem(title: "會員專區", image: UIImage(named: "circle-user-7.png"), tag: 0)
        rightTab.tabBarItem = rightTabBarItem
        
        // Navigation
        let rightNavigation = UINavigationController(rootViewController: rightTab)
        
        //            let leftTab = MenuTableViewController()
        let leftTab = storyboard.instantiateViewController(withIdentifier: "MenuTableViewController") as! MenuTableViewController
        leftTab.title = "TravelByMyself"
        
        let leftTabBarItem = UITabBarItem(title: "旅遊選單", image: UIImage(named: "airplane-symbol-7.png"), tag: 0)
        leftTab.tabBarItem = leftTabBarItem
        
        // Navigation
        let leftNavigation = UINavigationController(rootViewController: leftTab)
        
        rootTabBarController.viewControllers = [leftNavigation, rightNavigation]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = rootTabBarController
    }
    
    
}
