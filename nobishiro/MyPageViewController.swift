//
//  MyPageViewController.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/9/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import UIKit
import Haneke
import Himotoki
import Social
import Alamofire

class MyPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AutoReloadDelegate  {

    @IBOutlet weak var mesImageView: UIImageView!
    @IBOutlet weak var myWorksTableView: UITableView!

    private let refreshControl = UIRefreshControl()
    private var works: [Work] = [] {
        didSet {
            myWorksTableView.reloadData()
            if works.count > 0{
                mesImageView.hidden = true
            }else{
                mesImageView.hidden = false
            }
        }
    }
    private var myFavorites: [Int] = [] {
        didSet {
            myWorksTableView.reloadData()
        }
    }

    let identifiers = ["TwoPanelMangaTableViewCell", "ThreePanelMangaTableViewCell", "FourPanelMangaTableViewCell"]

    override func viewDidLoad() {
        super.viewDidLoad()
        myWorksTableView.dataSource = self
        myWorksTableView.delegate = self
        myWorksTableView.allowsSelection = false
        
        let titleImageView = UIImageView(image: UIImage(named: "myPageNav"))
        self.navigationItem.titleView = titleImageView

        for identifier in identifiers {
            myWorksTableView.registerNib(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }

        loadWorks()
        loadFavorites()

        refreshControl.addTarget(self, action: "loadWorks", forControlEvents: .ValueChanged)
        myWorksTableView.addSubview(refreshControl)

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "reloadTimeline:", name: "ReloadTimeline", object: nil)
        notificationCenter.addObserver(self, selector: "reloadTimelineMyPage:", name: "ReloadTimelineMyPage", object: nil)

    }

    func loadWorks() {
        let userID: Int!

        Alamofire.request(.GET, "http://yuji.website:3001/api/work?user_id=\(UserDefaults.getUserID())")
            .responseJSON { request, response, JSON, error in
                switch (JSON, error) {
                case (.Some(let json), .None):
                    if let worksData: WorksData = decode(json) {
                        self.works = worksData.data
                    }
                case (.None, .Some):
                    println("error!!!: \(error)")
                default:
                    println("both json and error are nil!")
                }
                self.refreshControl.endRefreshing()
        }
    }

    func loadFavorites() {
        Alamofire.request(.GET, "http://yuji.website:3001/api/favorite?user_id=\(UserDefaults.getUserID())")
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
            return WorkCell.calculateCellHeight(2, title: works[indexPath.row].title)
        case 3:
            return WorkCell.calculateCellHeight(3, title: works[indexPath.row].title)
        case 4:
            return WorkCell.calculateCellHeight(4, title: works[indexPath.row].title)
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let materials = works[indexPath.row].materials

        switch materials.count {
        case 2:

            let cell = myWorksTableView.dequeueReusableCellWithIdentifier(identifiers[0]) as! TwoPanelMangaTableViewCell

            cell.title.text = works[indexPath.row].title

            cell.firstPanel.hnk_setImageFromURL(NSURL(string: materials[0].url)!)
            cell.secondPanel.hnk_setImageFromURL(NSURL(string: materials[1].url)!)

            cell.postToTwitter.tag = works[indexPath.row].workId
            cell.postToTwitter.addTarget(self, action: "shareWithTwitter:", forControlEvents: .TouchUpInside)
            cell.postToFacebook.tag = works[indexPath.row].workId
            cell.postToFacebook.addTarget(self, action: "shareWithFacebook:", forControlEvents: .TouchUpInside)
            cell.postToLine.tag = works[indexPath.row].workId
            cell.postToLine.addTarget(self, action: "shareWithLINE:", forControlEvents: .TouchUpInside)

            cell.postToFavorite.enabled = false
            cell.postToFavorite.setImage(UIImage(named: "star-mine"), forState: .Normal)

            if works[indexPath.row].favoriteCount > 1000 {
                let double: Double = Double(works[indexPath.row].favoriteCount) / 1000
                cell.favoriteCount.text = String(format: "%.1fK", double)
            } else {
                cell.favoriteCount.text = String(works[indexPath.row].favoriteCount)
            }

            return cell

        case 3:

            let cell = myWorksTableView.dequeueReusableCellWithIdentifier(identifiers[1]) as! ThreePanelMangaTableViewCell

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

            cell.postToFavorite.enabled = false
            cell.postToFavorite.setImage(UIImage(named: "star-mine"), forState: .Normal)

            if works[indexPath.row].favoriteCount > 1000 {
                let double: Double = Double(works[indexPath.row].favoriteCount) / 1000
                cell.favoriteCount.text = String(format: "%.1fK", double)
            } else {
                cell.favoriteCount.text = String(works[indexPath.row].favoriteCount)
            }

            return cell

        case 4:

            let cell = myWorksTableView.dequeueReusableCellWithIdentifier(identifiers[2]) as! FourPanelMangaTableViewCell

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

            cell.postToFavorite.enabled = false
            cell.postToFavorite.setImage(UIImage(named: "star-mine"), forState: .Normal)

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

    func shareWithTwitter(sender: UIButton) {
        println("shareWithTwitter")
        SNS.shareWithSNS(self, sns: .Twitter, workID: sender.tag)
    }

    func shareWithFacebook(sender: UIButton) {
        println("shareWithFacebook")
        SNS.shareWithSNS(self, sns: .Facebook, workID: sender.tag)
    }

    func shareWithLINE(sender: UIButton) {
        println("shareWithLINE")
        SNS.shareWithSNS(self, sns: .LINE, workID: sender.tag)
    }

    func reloadTimeline(center: NSNotificationCenter) {
        loadWorks()
    }

    func autoReload() {
        println("MyPageController: autoload")
        loadWorks()
    }
    
    func reloadTimelineMyPage(center: NSNotificationCenter) {
        loadWorks()
        let topIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if works.count > 0 {
            myWorksTableView.scrollToRowAtIndexPath(topIndexPath, atScrollPosition: .Top, animated: false)
        }
    }

}
