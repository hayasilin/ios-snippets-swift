//
//  HomeTableViewCell.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import SDWebImage

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func update(with hotArticle: HotArticle){
        
        let imageUrlString = hotArticle.img_list?.first
        let imageUrl = URL(string: imageUrlString!)
        
        titleLabel.text = hotArticle.title
        descLabel.text = hotArticle.desc
        articleImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "no_image") , options: SDWebImageOptions(rawValue: 0), completed: nil)
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
