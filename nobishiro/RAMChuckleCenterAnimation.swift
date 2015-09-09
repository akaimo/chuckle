//
//  RAMChuckleCenterAnimation.swift
//  nobishiro
//
//  Created by Yuji Fujisaka on 9/10/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import UIKit

class RAMChuckleCenterAnimation : RAMItemAnimation {
    
    override func playAnimation(icon : UIImageView, textLabel : UILabel) {
        textLabel.textColor = textSelectedColor
        icon.hidden = true
        textLabel.hidden = true
    }
    
    override func deselectAnimation(icon : UIImageView, textLabel : UILabel, defaultTextColor : UIColor) {
        textLabel.textColor = defaultTextColor
        icon.hidden = false
        textLabel.hidden = false
        
        if let iconImage = icon.image {
            let renderImage = iconImage.imageWithRenderingMode(.AlwaysOriginal)
            icon.image = renderImage
            icon.tintColor = defaultTextColor
        }
    }
    
    override func selectedState(icon : UIImageView, textLabel : UILabel) {
        textLabel.textColor = textSelectedColor
    }
    
}
