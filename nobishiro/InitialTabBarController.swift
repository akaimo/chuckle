//
//  InitialTabBarController.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/7/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import UIKit

class InitialTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.

        let normalAttributes: [NSObject: AnyObject] = [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.65)]
        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, forState: .Normal)
        let selectedAttributes: [NSObject: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, forState: .Selected)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController is NavigationToPostingViewController {
            if let currentViewController = self.selectedViewController {
                let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationToPosting") as! UINavigationController
                nextViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                currentViewController.presentViewController(nextViewController, animated: true, completion: nil)
            }
            return false
        }
        return true
    }

}
