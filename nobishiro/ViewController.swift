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
import CoreGraphics
import QuartzCore
import Social

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var timelineTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private var works: [Work] = [] {
        didSet {
            timelineTableView.reloadData()
        }
    }

    let identifiers = ["TwoPanelMangaTableViewCell", "ThreePanelMangaTableViewCell", "FourPanelMangaTableViewCell"]

    override func viewDidLoad() {
        super.viewDidLoad()
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        timelineTableView.allowsSelection = false

        for identifier in identifiers {
            timelineTableView.registerNib(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }

        loadWorks()

        refreshControl.addTarget(self, action: "loadWorks", forControlEvents: .ValueChanged)
        timelineTableView.addSubview(refreshControl)
    }

    func loadWorks() {
        let cache = Cache<JSON>(name: "works")
        let URL = NSURL(string: "http://yuji.website:3001/api/work")!

        cache.fetch(URL: URL).onSuccess{ JSON in
            if let json = JSON.dictionary,
                worksData: WorksData = decode(json) {
                self.works = worksData.data
                println(worksData.data)
                println(worksData.error)
                println(worksData.next)
            } else {
                println("can't decode")
            }
            self.refreshControl.endRefreshing()
        }.onFailure{Failer in
            println(Failer)
            self.refreshControl.endRefreshing()
        }

        let cacheFavo = Cache<JSON>(name: "favorites")
        let URLFavo = NSURL(string: "http://yuji.website:3001/api/favorite")!

        println("favo")
        cacheFavo.fetch(URL: URLFavo).onSuccess{ JSON in
            if let json = JSON.dictionary,
                favoritesData: FavoritesData = decode(json) {
                    println(favoritesData.data)
                    println(favoritesData.status)
            } else {
                println("can't decode")
            }
            }.onFailure{Failer in
                println(Failer)
        }

        println("ranking")
        let cacheRank = Cache<JSON>(name: "ranking")
        let URLRank = NSURL(string: "http://yuji.website:3001/api/ranking")!
        cacheRank.fetch(URL: URLRank).onSuccess{ JSON in
            if let json = JSON.dictionary,
                rankingData: RankingData = decode(json) {
                    println(rankingData.data)
                    println(rankingData.status)
            } else {
                println("cant")
            }
            }.onFailure{Failer in
                println(Failer)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return works.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch works[indexPath.row].materials.count {
        case 2:
            return TwoPanelMangaTableViewCell.height()
        case 3:
            return ThreePanelMangaTableViewCell.height()
        case 4:
            return FourPanelMangaTableViewCell.height()
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let materials = works[indexPath.row].materials

        switch materials.count {
        case 2:
            let cell = timelineTableView.dequeueReusableCellWithIdentifier(identifiers[0]) as! TwoPanelMangaTableViewCell
            cell.title.text = NSDate().description
            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            return cell
        case 3:
            let cell = timelineTableView.dequeueReusableCellWithIdentifier(identifiers[1]) as! ThreePanelMangaTableViewCell
            cell.title.text = NSDate().description
            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            cell.thirdPanel.hnk_setImageFromURL(NSURL(string: materials[2].url)!)
            return cell
        case 4:
            let cell = timelineTableView.dequeueReusableCellWithIdentifier(identifiers[2]) as! FourPanelMangaTableViewCell
            cell.title.text = NSDate().description
            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            cell.thirdPanel.hnk_setImageFromURL(NSURL(string: materials[2].url)!)
            cell.fourPanel.hnk_setImageFromURL(NSURL(string: materials[3].url)!)
            return cell
        default:
            return UITableViewCell()
        }
    }

    func makeImageAndTweet(sender: UIButton) {
        let panels = 4
        let images: [UIImage] = []
        UIGraphicsBeginImageContext(CGSizeMake(150, CGFloat(150 * panels)))
        for (i, image) in enumerate(images) {
            image.drawAtPoint(CGPointMake(0, CGFloat(150 * i)))
        }
        let mangaImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let composeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        composeView.setInitialText("")
        composeView.addImage(mangaImage)
        self.presentViewController(composeView, animated: true, completion: nil)
    }
}

