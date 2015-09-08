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
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var timelineTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private var works: [Work] = [] {
        didSet {
            timelineTableView.reloadData()
        }
    }
    private var myFavorites: [Int] = [] {
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
        loadFavorites()

        refreshControl.addTarget(self, action: "loadWorks", forControlEvents: .ValueChanged)
        timelineTableView.addSubview(refreshControl)
    }

    func loadWorks() {
        Alamofire.request(.GET, "http://yuji.website:3001/api/work")
            .responseJSON { request, response, JSON, error in
                switch (JSON, error) {
                case (.Some(let json), .None):
                    if let worksData: WorksData = decode(json) {
                        self.works = worksData.data
                    }
                case (.None, .Some):
                    println(error)
                default:
                    println("both json and error are nil!")
                }
                self.refreshControl.endRefreshing()
        }
/*

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
        }*/
    }

    func loadFavorites() {
        Alamofire.request(.GET, "http://yuji.website:3001/api/favorite")
            .responseJSON { request, response, JSON, error in
                switch (JSON, error) {
                case (.Some(let json), .None):
                    if let favoritesData: FavoritesData = decode(json) {
                        self.myFavorites = favoritesData.data.map{$0.workId}
                    }
                case (.None, .Some):
                    println(error)
                default:
                    println("both json and error are nil!")
                }
                self.refreshControl.endRefreshing()
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
            cell.title.text = works[indexPath.row].title
            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            //cell.postToTwitter.tag = works[indexPath.row].workId
            //cell.postToTwitter.addTarget(self, action: "shareWithTwitter:", forControlEvents: .TouchUpInside)
            cell.postToFavorite.tag = works[indexPath.row].workId
            cell.postToFavorite.addTarget(self, action: "postToFavorite:", forControlEvents: .TouchUpInside)
            return cell

        case 3:

            let cell = timelineTableView.dequeueReusableCellWithIdentifier(identifiers[1]) as! ThreePanelMangaTableViewCell

            cell.title.text = works[indexPath.row].title

            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            cell.thirdPanel.hnk_setImageFromURL(NSURL(string: materials[2].url)!)

            cell.postToFavorite.tag = works[indexPath.row].workId
            cell.postToFavorite.addTarget(self, action: "postToFavorite:", forControlEvents: .TouchUpInside)

            if (myFavorites.reduce(false){$0 || $1 == works[indexPath.row].workId}){
                println("yellow")
                cell.postToFavorite.backgroundColor = UIColor.yellowColor()
            } else {
                println("black")
                cell.postToFavorite.backgroundColor = UIColor.grayColor()
            }

            if works[indexPath.row].favoriteCount > 1000 {
                let double: Double = Double(works[indexPath.row].favoriteCount) / 1000
                cell.favoriteCount.text = String(format: "%.1fK", double)
            } else {
                cell.favoriteCount.text = String(works[indexPath.row].favoriteCount)
            }

            return cell

        case 4:
            let cell = timelineTableView.dequeueReusableCellWithIdentifier(identifiers[2]) as! FourPanelMangaTableViewCell
            cell.title.text = works[indexPath.row].title
            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            cell.thirdPanel.hnk_setImageFromURL(NSURL(string: materials[2].url)!)
            cell.fourPanel.hnk_setImageFromURL(NSURL(string: materials[3].url)!)
            return cell
        default:
            return UITableViewCell()
        }
    }

    func postToFavorite(sender: UIButton) {
        println(sender.tag)
        Alamofire.request(.POST, "http://yuji.website:3001/api/favorite?work_id=\(sender.tag)", parameters: nil, encoding: .JSON).responseJSON{ request, response, JSON, error in
            switch (JSON, error) {
            case (.Some, .None):
                self.loadWorks()
                self.loadFavorites()
            default:
                println("error")
            }
        }
    }
/*
    func findWork(workId: Int) -> Work? {
        for work in works {
            if work.workId == workId {
                return work
            }
        }
        return nil
    }

    func shareWithTwitter(sender: UIButton) {
        let composeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        if let work = findWork(sender.tag) {
            composeView.setInitialText("\(work.title)だよ!")
            composeView.addImage(makeImage(work.workId))
            self.presentViewController(composeView, animated: true, completion: nil)
        } else {
            println("cant find work")
        }
    }

    func line() {
        let pasteBoard = UIPasteboard.pasteboardWithUniqueName()
        pasteBoard.setData(UIImagePNGRepresentation(makeImage([])), forPasteboardType: "public.png")
        let lineURLString = "line://msg/image/\(pasteBoard.name)"

        UIApplication.sharedApplication().openURL(NSURL(string: lineURLString)!)
    }

    func makeImage(workId: Int) -> UIImage {
        let URLs = findWork(workId)?.materials.map{$0.url}
        let cache = Shared.imageCache
        let images: [UIImage] = []
        UIGraphicsBeginImageContext(CGSizeMake(150, CGFloat(150 * images.count)))
        for (i, image) in enumerate(images) {
            image.drawAtPoint(CGPointMake(0, CGFloat(150 * i)))
        }
        let mangaImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return mangaImage
    }*/
}

