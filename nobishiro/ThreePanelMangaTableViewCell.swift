//
//  ThreePanelMangaTableViewCell.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/3/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import UIKit

class ThreePanelMangaTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var firstPanel: UIImageView!
    @IBOutlet weak var secondPanel: UIImageView!
    @IBOutlet weak var thirdPanel: UIImageView!

    @IBOutlet weak var postToTwitter: UIButton!
    @IBOutlet weak var postToFacebook: UIButton!
    @IBOutlet weak var postToLine: UIButton!
    @IBOutlet weak var postToFavorite: UIButton!

    @IBOutlet weak var favoriteCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    class func height(title: String) -> CGFloat {
        let calculationLabel = UILabel()
        calculationLabel.text = title
        let size = calculationLabel.sizeThatFits(CGSizeMake(284, CGFloat.max))
        return size.height
    }

    override func prepareForReuse() {
        title.text = nil
        firstPanel.image = nil
        secondPanel.image = nil
        thirdPanel.image = nil
        favoriteCount.text = nil
        postToFavorite.enabled = false
        postToFavorite.setImage(nil, forState: .Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
