//
//  NotificationTableViewController.swift
//  nobishiro
//
//  Created by Yuji Fujisaka on 9/8/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import UIKit

class NotificationTableViewController: UIViewController {

    @IBOutlet private weak var notificationTableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
