//
//  PostingTableViewCell.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/04.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit

class PostingTableViewCell: UITableViewCell {
    @IBOutlet weak var postingImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        postingImageView.image = nil
    }
    
}
