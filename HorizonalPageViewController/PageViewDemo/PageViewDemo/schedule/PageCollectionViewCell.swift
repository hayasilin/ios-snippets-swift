//
//  PageCollectionViewCell.swift
//  Travostyle
//
//  Created by Jeff on 2017/5/9.
//  Copyright © 2017年 Jeff. All rights reserved.
//

import UIKit

class PageCollectionViewCell: UICollectionViewCell {

    static let identifier = "PageCollectionViewCell"
    
    @IBOutlet weak fileprivate var titleLabel: UILabel!
    @IBOutlet weak fileprivate var selectView: UIView!
    
    var pageType: PageType = .fragment {
        didSet {
            titleLabel.text = pageType.title
        }
    }
    
    var isNowPage: Bool = false {
        didSet {
            if isNowPage {
                titleLabel.textColor = UIColor.purple
                selectView.backgroundColor = UIColor.purple
            } else {
                titleLabel.textColor = UIColor.cyan
                selectView.backgroundColor = UIColor.white
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 14)
    }
}
