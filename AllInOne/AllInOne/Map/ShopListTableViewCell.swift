//
//  ShopListTableViewCell.swift
//  AllInOne
//
//  Created by KuanWei on 2018/1/5.
//  Copyright © 2018年 cracktheterm. All rights reserved.
//

import UIKit

class ShopListTableViewCell: UITableViewCell {


    @IBOutlet weak var shopImageView: UIImageView!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopAddressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
