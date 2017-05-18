//
//  ContinentalView.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/12.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

protocol ContinentalViewDelegate: NSObjectProtocol {
    func ContinentalView(ContinentalView: ContinentalView, sectionOpened: Int)
    func ContinentalView(ContinentalView: ContinentalView, sectionClosed: Int)
}

class ContinentalView: UITableViewHeaderFooterView {
    @IBOutlet weak var continentalName: UILabel!
    
    @IBOutlet weak var headerImg: UIImageView!
    
    var delegate: ContinentalViewDelegate!
    var section: Int!
    var isHeaderOpen: Bool = false
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        // 設置disclosure 按鈕圖片(被打開
//        arrowBtn.setImage(UIImage(named: "arrowOpen.png"), for: UIControlState.selected)
        
        headerImg.image = UIImage(named: "arrowClose.png")
        
        // 單擊手勢識別
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ContinentalView.closureBtnPress(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func closureBtnPress(_ sender: UITapGestureRecognizer) {
        self.closureStateChange(userAction: true)
    }
    
    func closureStateChange(userAction: Bool) {
        
        if(userAction){
            
            if(isHeaderOpen){
                delegate.ContinentalView(ContinentalView: self, sectionClosed: section)
                
                headerImg.image = UIImage(named: "arrowClose.png")
            }
            else{
                delegate.ContinentalView(ContinentalView: self, sectionOpened: section)
                
                headerImg.image = UIImage(named: "arrowOpen.png")
            }
        }
        
    }

}
