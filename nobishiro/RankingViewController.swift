//
//  RankingViewController.swift
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

class RankingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var rankingTableView: UITableView!

    private let refreshControl = UIRefreshControl()
    private var works: [Work] = [] {
        didSet {
                rankingTableView.reloadData()
            }
        }
        private var myFavorites: [Int] = [] {
            didSet {
                rankingTableView.reloadData()
            }
        }

        let identifiers = ["TwoPanelMangaTableViewCell", "ThreePanelMangaTableViewCell", "FourPanelMangaTableViewCell"]

        override func viewDidLoad() {
            super.viewDidLoad()
            rankingTableView.dataSource = self
            rankingTableView.delegate = self
            rankingTableView.allowsSelection = false

            let titleImageView = UIImageView(image: UIImage(named: "rankingNav"))
            self.navigationItem.titleView = titleImageView
        
            for identifier in identifiers {
                rankingTableView.registerNib(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
            }

            loadWorks()
            loadFavorites()

            refreshControl.addTarget(self, action: "loadWorks", forControlEvents: .ValueChanged)
            rankingTableView.addSubview(refreshControl)
        }

        func loadWorks() {
            Alamofire.request(.GET, "http://yuji.website:3001/api/ranking")
                .responseJSON { request, response, JSON, error in
                    switch (JSON, error) {
                    case (.Some(let json), .None):
                        if let rankingData: RankingData = decode(json) {
                            self.works = rankingData.data
                        }
                    case (.None, .Some):
                        println(error)
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

                let cell = rankingTableView.dequeueReusableCellWithIdentifier(identifiers[0]) as! TwoPanelMangaTableViewCell

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

                if works[indexPath.row].userId == UserDefaults.getUserID() {
                    cell.postToFavorite.enabled = false
                    cell.postToFavorite.setImage(nil, forState: .Normal)
                } else if contains(myFavorites, works[indexPath.row].workId) {
                    cell.postToFavorite.enabled = false
                    cell.postToFavorite.setImage(UIImage(named: "starred"), forState: .Normal)
                } else {
                    cell.postToFavorite.enabled = true
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

                let cell = rankingTableView.dequeueReusableCellWithIdentifier(identifiers[1]) as! ThreePanelMangaTableViewCell

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

                if works[indexPath.row].userId == UserDefaults.getUserID() {
                    cell.postToFavorite.enabled = false
                    cell.postToFavorite.setImage(nil, forState: .Normal)
                } else if contains(myFavorites, works[indexPath.row].workId) {
                    cell.postToFavorite.enabled = false
                    cell.postToFavorite.setImage(UIImage(named: "starred"), forState: .Normal)
                } else {
                    cell.postToFavorite.enabled = true
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

                let cell = rankingTableView.dequeueReusableCellWithIdentifier(identifiers[2]) as! FourPanelMangaTableViewCell

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

                if works[indexPath.row].userId == UserDefaults.getUserID() {
                    cell.postToFavorite.enabled = false
                    cell.postToFavorite.setImage(nil, forState: .Normal)
                } else if contains(myFavorites, works[indexPath.row].workId) {
                    cell.postToFavorite.enabled = false
                    cell.postToFavorite.setImage(UIImage(named: "starred"), forState: .Normal)
                } else {
                    cell.postToFavorite.enabled = true
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
        sender.enabled = false
        sender.setImage(UIImage(named: "starred"), forState: .Normal)
        //未ふぁぼなのでふぁぼする
        if !contains(myFavorites, sender.tag) {
            Alamofire.request(.POST, "http://yuji.website:3001/api/favorite?user_id=\(UserDefaults.getUserID())&work_id=\(sender.tag)", parameters: nil, encoding: .JSON).responseJSON{ request, response, JSON, error in
                switch (JSON, error) {
                case (.Some(let json), .None):
                    //self.loadWorks()
                    self.loadFavorites()
                default:
                    println("error")
                }
            }
        } else {
            //あんふぁぼ?
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
}
