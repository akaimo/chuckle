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

            cell.postToTwitter.tag = works[indexPath.row].workId
            cell.postToTwitter.addTarget(self, action: "shareWithTwitter:", forControlEvents: .TouchUpInside)
            cell.postToFacebook.tag = works[indexPath.row].workId
            cell.postToFacebook.addTarget(self, action: "shareWithFacebook:", forControlEvents: .TouchUpInside)
            cell.postToLine.tag = works[indexPath.row].workId
            cell.postToLine.addTarget(self, action: "shareWithLINE:", forControlEvents: .TouchUpInside)
            cell.postToFavorite.tag = works[indexPath.row].workId
            cell.postToFavorite.addTarget(self, action: "postToFavorite:", forControlEvents: .TouchUpInside)

            if (myFavorites.reduce(false){$0 || $1 == works[indexPath.row].workId}){
                cell.postToFavorite.setImage(UIImage(named: "starred"), forState: .Normal)
            } else {
                cell.postToFavorite.setImage(UIImage(named: "star"), forState: .Normal)
            }

            if works[indexPath.row].favoriteCount > 1000 {
                let double: Double = Double(works[indexPath.row].favoriteCount) / 1000
                cell.favoriteCount.text = String(format: "%.1fK", double)
            } else {
                cell.favoriteCount.text = String(works[indexPath.row].favoriteCount)
            }

            return cell

        case 3:

            let cell = timelineTableView.dequeueReusableCellWithIdentifier(identifiers[1]) as! ThreePanelMangaTableViewCell

            cell.title.text = works[indexPath.row].title

            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)
            cell.thirdPanel.hnk_setImageFromURL(NSURL(string: materials[2].url)!)

            cell.postToTwitter.tag = works[indexPath.row].workId
            cell.postToTwitter.addTarget(self, action: "shareWithTwitter:", forControlEvents: .TouchUpInside)
            cell.postToFacebook.tag = works[indexPath.row].workId
            cell.postToFacebook.addTarget(self, action: "shareWithFacebook:", forControlEvents: .TouchUpInside)
            cell.postToLine.tag = works[indexPath.row].workId
            cell.postToLine.addTarget(self, action: "shareWithLINE:", forControlEvents: .TouchUpInside)
            cell.postToFavorite.tag = works[indexPath.row].workId
            cell.postToFavorite.addTarget(self, action: "postToFavorite:", forControlEvents: .TouchUpInside)

            if (myFavorites.reduce(false){$0 || $1 == works[indexPath.row].workId}){
                cell.postToFavorite.setImage(UIImage(named: "starred"), forState: .Normal)
            } else {
                cell.postToFavorite.setImage(UIImage(named: "star"), forState: .Normal)
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

            cell.postToTwitter.tag = works[indexPath.row].workId
            cell.postToTwitter.addTarget(self, action: "shareWithTwitter:", forControlEvents: .TouchUpInside)
            cell.postToFacebook.tag = works[indexPath.row].workId
            cell.postToFacebook.addTarget(self, action: "shareWithFacebook:", forControlEvents: .TouchUpInside)
            cell.postToLine.tag = works[indexPath.row].workId
            cell.postToLine.addTarget(self, action: "shareWithLINE:", forControlEvents: .TouchUpInside)
            cell.postToFavorite.tag = works[indexPath.row].workId
            cell.postToFavorite.addTarget(self, action: "postToFavorite:", forControlEvents: .TouchUpInside)

            if (myFavorites.reduce(false){$0 || $1 == works[indexPath.row].workId}){
                cell.postToFavorite.setImage(UIImage(named: "starred"), forState: .Normal)
            } else {
                cell.postToFavorite.setImage(UIImage(named: "star"), forState: .Normal)
            }

            if works[indexPath.row].favoriteCount > 1000 {
                let double: Double = Double(works[indexPath.row].favoriteCount) / 1000
                cell.favoriteCount.text = String(format: "%.1fK", double)
            } else {
                cell.favoriteCount.text = String(works[indexPath.row].favoriteCount)
            }

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

    enum SNS {
        case Twitter
        case Facebook
        case LINE
    }
    func postToSocial(forServiceType: String, image: UIImage) {
        let composeView = SLComposeViewController(forServiceType: forServiceType)
        composeView.setInitialText("何が好きでXcode開いてるのにvimでSwift書かないといけないんですかね(激怒)")
        composeView.addImage(image)
        self.presentViewController(composeView, animated: true, completion: nil)
    }
    func postToLINE(image: UIImage) {
        let pasteBoard = UIPasteboard.pasteboardWithUniqueName()
        pasteBoard.setData(UIImagePNGRepresentation(image), forPasteboardType: "chuckle.png")
        let lineURLString = "line://msg/image/\(pasteBoard.name)"
        UIApplication.sharedApplication().openURL(NSURL(string: lineURLString)!)
    }
    func shareWithSNS(sns: SNS, workID: Int) {
        let cache = Cache<UIImage>(name: "shareImage")
        Alamofire.request(.GET, "http://yuji.website:3001/api/share_image/\(workID)", parameters: nil, encoding: .JSON).responseJSON{ request, response, JSON, error in
            switch (JSON, error) {
            case (.Some(let json), .None):
                println(json)
                if let shareImageData: ShareImageData = decode(json) {
                    let URL = NSURL(string: shareImageData.data)!
                    cache.fetch(URL: URL).onSuccess{ image in
                        switch sns {
                        case .Twitter:
                            println("type: twitter")
                            self.postToSocial(SLServiceTypeTwitter, image: image)
                        case .Facebook:
                            println("type: facebook")
                            self.postToSocial(SLServiceTypeFacebook, image: image)
                        case .LINE:
                            println("type: line")
                            self.postToLINE(image)
                        }
                    }.onFailure{ Failer in
                            println(Failer)
                    }
                } else {
                    println("cant decode")
                }
            default:
                println(error)
            }
        }
    }

    func shareWithTwitter(sender: UIButton) {
        println("shareWithTwitter")
        shareWithSNS(.Twitter, workID: sender.tag)
    }

    func shareWithFacebook(sender: UIButton) {
        println("shareWithFacebook")
        shareWithSNS(.Facebook, workID: sender.tag)
    }

    func shareWithLINE(sender: UIButton) {
        println("shareWithLINE")
        shareWithSNS(.LINE, workID: sender.tag)
    }
}

struct ShareImageData: Decodable  {
    let data: String
    let status: String

    static func decode(e: Extractor) -> ShareImageData? {
        let create = { ShareImageData($0) }

        return build(create)(
            e <| "data",
            e <| "status"
        )
    }
}
