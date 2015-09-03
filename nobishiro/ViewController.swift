//
//  ViewController.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/03.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var timelineTableView: UITableView!

    let sampleIdentifier = ["TwoPanelManga", "ThreePanelManga", "FourPanelManga"]

    override func viewDidLoad() {
        super.viewDidLoad()

        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        timelineTableView.allowsSelection = false

        for identifier in sampleIdentifier {
            timelineTableView.registerNib(UINib(nibName: "\(identifier)TableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //MARK: TODO
        return 10
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //MARK: TODO
        switch indexPath.row % 3 {
        case 1:
            return 320
        case 2:
            return 474
        default:
            return 628
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //MARK: TODO
        let cell: UITableViewCell!
        switch indexPath.row % 3 {
        case 1:
            cell = timelineTableView.dequeueReusableCellWithIdentifier(sampleIdentifier[0]) as! TwoPanelMangaTableViewCell
        case 2:
            cell = timelineTableView.dequeueReusableCellWithIdentifier(sampleIdentifier[1]) as! ThreePanelMangaTableViewCell
        default:
            cell = timelineTableView.dequeueReusableCellWithIdentifier(sampleIdentifier[2]) as! FourPanelMangaTableViewCell
        }
        return cell
    }
}

