//
//  PocketSpotTVCell.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/5.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class PocketSpotTVCell: UITableViewCell {
    
    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var selectStatus: UILabel!
    @IBOutlet weak var addSpotBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        spotName.lineBreakMode = .byTruncatingTail
        spotImage.layer.cornerRadius = 10.0
        spotImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
