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

class NotificationTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var notificationTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private var notification: [Notification] = [] {
      didSet {
        notificationTableView.reloadData()
      }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTableView.dataSource = self
        notificationTableView.delegate = self
        notificationTableView.allowsSelection = false
        loadNotifications()
        refreshControl.addTarget(self, action: "loadNotifications", forControlEvents: .ValueChanged)
        notificationTableView.addSubview(refreshControl)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func loadView() {
      if let view = UINib(nibName: "NotificationTableViewController", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
        self.view = view
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notification.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
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
        
        Alamofire.request(.GET, "http://yuji.website:3001/api/favorite/\(userID)")
        .responseJSON { request, response, JSON, error in
            println(request)
            println(response)
            println(JSON)
            println(error)
            switch (JSON, error) {
            case (.Some(let json), .None):
                if let notificationsData: NotificationsData = decode(json) {
                    self.notification = notificationsData.data
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
