//
//  ShopCommentTableViewCell.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/20/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit

class ShopCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
