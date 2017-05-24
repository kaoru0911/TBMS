//
//  ScheduleTableViewCell.swift
//  TravelByMyself
//
//  Created by popcool on 2017/4/25.
//  Copyright © 2017年 Arwin Tsai. All rights reserved.
//

import UIKit


class ScheduleTableViewCell: UITableViewCell {
    
    let spotArray:Array = ["清水寺", "平等院", "宇治"]
    let spotTraffic:Array = ["十號公車車車車車車車車車車車車車車車車車車車", "二號公車", "五號公車"]
    
    @IBOutlet weak var describeLabel: UILabel!

    @IBOutlet weak var spotItemLabel: UILabel!
    
    @IBOutlet weak var cellImage: UIImageView!
    
//    var cellImage: UIImageView!
//    var describeLabel: UILabel!
//    var spotItemLabel: UILabel!
    
    var screenSize: CGRect!
    
    let spotLabelWidth: CGFloat = 230
    let spotLabelHeight: CGFloat = 20
    let describeLabelWidth: CGFloat = 190
    let describeLabelHeight: CGFloat = 200      // max height
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    /*
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 取得螢幕大小
        screenSize = UIScreen.main.bounds
        
        // 計算位置
        let spotLabelPositionX = (screenSize.width - spotLabelWidth)/2
        let spotLabelPositionY: CGFloat = 0.0
        
        // 建立一個標頭label
        spotItemLabel = UILabel(frame: CGRect(x: spotLabelPositionX, y: spotLabelPositionY, width: spotLabelWidth, height: spotLabelHeight))
        spotItemLabel.textAlignment = NSTextAlignment.center
        spotItemLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        // 加入到容器內
        self.contentView.addSubview(spotItemLabel)
        
        spotItemLabel.text = spotArray[0]
        
        spotItemLabel.backgroundColor = UIColor(red: 152/255, green: 221/255, blue: 222/255, alpha: 1)

        
//        spotItemLabel.translatesAutoresizingMaskIntoConstraints = false
//        spotItemLabel.heightAnchor.constraint(equalToConstant: spotLabelHeight).isActive = true
//        spotItemLabel.widthAnchor.constraint(equalToConstant: spotLabelWidth).isActive = true
//        spotItemLabel.centerXAnchor.constraint(equalTo: spotItemLabel.superview!.centerXAnchor).isActive = true
        
        // 取得標頭label的x位置
        let describeLabelPositionX = spotLabelPositionX + 40
        let describeLabelPositionY = spotLabelPositionY + spotLabelHeight + 5
        
        // 建立描述label
        describeLabel = UILabel(frame: CGRect(x: describeLabelPositionX, y: describeLabelPositionY, width: describeLabelWidth, height: describeLabelHeight))
        describeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        // 加入到容器中
        self.contentView.addSubview(describeLabel)
        
        // 自動換行設定
        describeLabel.translatesAutoresizingMaskIntoConstraints = false
        describeLabel.text = spotTraffic[0]
        describeLabel.numberOfLines = 0
        describeLabel.sizeToFit()

        let cellImagePositionX = spotLabelPositionX
        let cellImagePositionY = spotLabelPositionY + spotLabelHeight + 5
        
        let labelCGsize = CGSize(width: spotLabelWidth, height: describeLabelHeight)
        
        let labelHeight = describeLabel.attributedText?.boundingRect(with: labelCGsize, options: .usesLineFragmentOrigin, context: nil)
        
        self.cellImage = UIImageView(frame: CGRect(x: 10.0, y: 15.0, width: 30, height: 30))
        self.cellImage.contentMode = UIViewContentMode.scaleAspectFill
        self.cellImage.clipsToBounds = true

        
        
        
        self.contentView.addSubview(self.cellImage)
    }*/
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
