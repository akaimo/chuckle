//
//  ViewController.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/03.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit
import Haneke
import Himotoki

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var timelineTableView: UITableView!
    private var works: [Work] = [] {
        didSet {
            timelineTableView.reloadData()
        }
    }

    let sampleIdentifier = ["TwoPanelManga", "ThreePanelManga", "FourPanelManga"]

    override func viewDidLoad() {
        super.viewDidLoad()

        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        timelineTableView.allowsSelection = false

        for identifier in sampleIdentifier {
            timelineTableView.registerNib(UINib(nibName: "\(identifier)TableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        }

        loadWorks()
    }

    func loadWorks() {
        let cache = Cache<JSON>(name: "works")
        let URL = NSURL(string: "http://yuji.website:3001/api/work")!

        cache.fetch(URL: URL).onSuccess{ JSON in
            if let json = JSON.dictionary,
                worksData: WorksData = decode(json) {
                self.works += worksData.data
            } else {
                println("can't decode")
            }
        }.onFailure{Failer in
            println(Failer)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return works.count
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

        let materials = works[indexPath.row].materials

        switch materials.count {
        case 2:
            let cell = timelineTableView.dequeueReusableCellWithIdentifier(sampleIdentifier[0]) as! TwoPanelMangaTableViewCell
            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            return cell
        case 3:
            let cell = timelineTableView.dequeueReusableCellWithIdentifier(sampleIdentifier[1]) as! ThreePanelMangaTableViewCell
            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            cell.thirdPanel.hnk_setImageFromURL(NSURL(string: materials[2].url)!)
            return cell
        case 4:
            let cell = timelineTableView.dequeueReusableCellWithIdentifier(sampleIdentifier[2]) as! FourPanelMangaTableViewCell
            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            cell.thirdPanel.hnk_setImageFromURL(NSURL(string: materials[2].url)!)
            cell.fourPanel.hnk_setImageFromURL(NSURL(string: materials[3].url)!)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

