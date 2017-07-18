//
//  TripListTableViewCell.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/12.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit

class TripListTableViewCell: UITableViewCell {

    @IBOutlet weak var tripSubTitle: UILabel!
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var tripCoverImg: UIImageView!
    
    var cellTripData: tripData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tripCoverImg.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
