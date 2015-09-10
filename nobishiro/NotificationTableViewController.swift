//
//  NotificationTableViewController.swift
//  nobishiro
//
//  Created by Yuji Fujisaka on 9/8/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import UIKit
import Himotoki
import Alamofire

class NotificationTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AutoReloadDelegate {

    @IBOutlet weak var mesImageView: UIImageView!
    @IBOutlet private weak var notificationTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private var notifications: [Notification] = [] {
      didSet {
        notificationTableView.reloadData()
        if notifications.count > 0{
            mesImageView.hidden = true
        }else{
            mesImageView.hidden = false
        }
      }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        notificationTableView.dataSource = self
        notificationTableView.delegate = self
        notificationTableView.allowsSelection = false
        self.automaticallyAdjustsScrollViewInsets = false;
        
        let titleImageView = UIImageView(image: UIImage(named: "alermNav"))
        self.navigationItem.titleView = titleImageView
        
        notificationTableView.registerNib(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        
        loadNotifications()
        refreshControl.addTarget(self, action: "loadNotifications", forControlEvents: .ValueChanged)
        notificationTableView.addSubview(refreshControl)
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "reloadTimelineNotifications:", name: "ReloadTimelineNotifications", object: nil)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    override func loadView() {
        if let view = UINib(nibName: "NotificationTableViewController", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
        self.view = view
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = notificationTableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell") as! NotificationTableViewCell
        
        let lblText = NSMutableAttributedString(string: "「」がお気に入りされました！")
        let title = NSMutableAttributedString(string: notifications[indexPath.row].title)
        title.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())], range: NSMakeRange(0, title.length))
        lblText.insertAttributedString(title, atIndex: 1)
        
        cell.title.attributedText = lblText
        cell.thumImageView.hnk_setImageFromURL(NSURL(string: notifications[indexPath.row].imageUrl)!)
        
        return cell
    }

  
    func loadNotifications() {
        
        var userID: AnyObject!
        var platform = platformName()
        if platform == "x86_64" {
            // simulator
            userID = 1
        } else {
            // 実機処理
            let ud = NSUserDefaults.standardUserDefaults()
            userID = ud.objectForKey("userID")
        }
        
        Alamofire.request(.GET, "http://yuji.website:3001/api/favorite?creator_id=\(userID)")
        .responseJSON { request, response, JSON, error in
            println(request)
            println(response)
            println(JSON)
            println(error)
            switch (JSON, error) {
            case (.Some(let json), .None):
                if let notificationsData: NotificationsData = decode(json) {
                    self.notifications = notificationsData.data
                }
            case (.None, .Some):
                println(error)
            default:
                println("both json and error are nil!")
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func platformName() -> String {
        var size: size_t = 0;
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = UnsafeMutablePointer<CChar>(malloc(size))
        sysctlbyname("hw.machine", machine, &size, nil, 0)
        var platformName = NSString(CString: machine, encoding: NSUTF8StringEncoding)
        free(machine)
        
        return platformName! as String
    }

    func autoReload() {
        println("NotificationController: autoload")
        loadNotifications()
    }
    
    func reloadTimelineNotifications(center: NSNotificationCenter) {
        loadNotifications()
        let topIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if notifications.count > 0 {
            notificationTableView.scrollToRowAtIndexPath(topIndexPath, atScrollPosition: .Top, animated: false)
        }
    }
}
