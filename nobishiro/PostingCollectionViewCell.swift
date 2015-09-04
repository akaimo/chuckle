//
//  PostingCollectionViewCell.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/04.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit

class PostingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var stampImageView: UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}
