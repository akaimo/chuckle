//
//  PostCollectionView.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/07.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit

class PostCollectionView: UIView {
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    class func instance() -> PostCollectionView {
        return UINib(nibName: "PostCollectionView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! PostCollectionView
    }

}
