//
//  SetStartPointViewController.swift
//  TBMS
//
//  Created by Ryder Tsai on 2017/5/12.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit

class SetStartPointViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
//        let goBackButton = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(goBackAddPointPage))
//        
//        self.navigationItem.leftBarButtonItem = goBackButton
        
        self.navigationController?.navigationBar.isHidden=false


    }
    
    func goBackAddPointPage() {
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addViewPointViewController = storyboard.instantiateViewController(withIdentifier :"AddViewPointViewController") as! AddViewPointViewController
        self.present(addViewPointViewController, animated: true)
        */
        
        
        
        
        //his mom
//        let vc : AddViewPointViewController = storyboard.instantiateViewController(withIdentifier: "AddViewPointViewController") as! AddViewPointViewController
//        
//        let navigationController = UINavigationController(rootViewController: vc)
//        
//        self.present(navigationController, animated: true)
        
        //hello world
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addViewPointViewController = storyboard.instantiateViewController(withIdentifier :"AddViewPointViewController") as! AddViewPointViewController

        self.navigationController?.pushViewController(addViewPointViewController, animated: true)
        
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

}
