//
//  WorkCell.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/9/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import UIKit

struct WorkCell {
    static func calculateCellHeight(numberOfPanels: Int, title: String) -> CGFloat {
        let calculationLabel = UILabel()
        calculationLabel.text = title
        calculationLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        calculationLabel.adjustsFontSizeToFitWidth = false
        var title = calculationLabel.sizeThatFits(CGSizeMake(284, CGFloat.max)).height
        //println("titleHeight: \(title)")
        title = 70

        let cellMargin = 8
        let titleLabelMargin = 10
        let spaceBetweenTitleAndPanel = 10
        let panel = 150
        let spaceBetweenPanels = 3
        let spaceBetweenPanelAndLine = 9
        let line = 1
        let shareButtonMargin = 10

        let margin = CGFloat(cellMargin + titleLabelMargin + shareButtonMargin) * 2
        let panels = CGFloat(panel * numberOfPanels + spaceBetweenPanels * (numberOfPanels - 1))
        let heights = CGFloat(spaceBetweenPanelAndLine + spaceBetweenTitleAndPanel + line) + title
        return CGFloat(margin + panels + heights)
    }
}