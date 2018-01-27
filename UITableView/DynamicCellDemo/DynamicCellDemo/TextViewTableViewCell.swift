//
//  TextViewTableViewCell.swift
//  DynamicCellDemo
//
//  Created by KuanWei on 2018/7/6.
//  Copyright © 2018年 Kuan-Wei. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
