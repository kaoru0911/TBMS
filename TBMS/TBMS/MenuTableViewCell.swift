//
//  MenuTableViewCell.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/11.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuCellImage: UIImageView!
    @IBOutlet weak var menuCellName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
