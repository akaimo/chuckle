//
//  InitialTabBarController.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/7/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import UIKit

class InitialTabBarController: UITabBarController, UITabBarControllerDelegate {
    var iconsView: [(icon: UIImageView, textLabel: UILabel)] = Array()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
        let containers = createViewContainers()
        createCustomIcons(containers)
        
        let normalAttributes: [NSObject: AnyObject] = [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.65)]
        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, forState: .Normal)
        let selectedAttributes: [NSObject: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, forState: .Selected)
        self.tabBar.tintColor = UIColor.whiteColor()
    //    self.tabBar.selectedImageTintColor = UIColor(red: 251/255.0, green: 212/255.0, blue: 146/255.0, alpha: 1.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: create methods
    
    func createCustomIcons(containers : NSDictionary) {
        
        if let items = tabBar.items {
            let itemsCount = items.count as Int - 1
            
            for (index, item) in enumerate(items as! [RAMAnimatedTabBarItem]) {
                
                assert(item.image != nil, "add image icon in UITabBarItem")
                
                let container : UIView = containers["container\(itemsCount-index)"] as! UIView
                container.tag = index
                
                let icon = UIImageView(image: item.image)
                icon.setTranslatesAutoresizingMaskIntoConstraints(false)
                icon.tintColor = UIColor.clearColor()
                
                // text
                let textLabel = UILabel()
                textLabel.text = item.title
                textLabel.backgroundColor = UIColor.clearColor()
                textLabel.textColor = item.textColor
                textLabel.font = UIFont.systemFontOfSize(10)
                textLabel.textAlignment = NSTextAlignment.Center
                textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
                
                container.addSubview(icon)
                
                if let itemImage = item.image {
                    createConstraints(icon, container: container, size: itemImage.size, yOffset: -5)
                }
                
                container.addSubview(textLabel)
                
                if let tabBarItem = tabBar.items {
                    let textLabelWidth = tabBar.frame.size.width / CGFloat(tabBarItem.count) - 5.0
                    createConstraints(textLabel, container: container, size: CGSize(width: textLabelWidth , height: 10), yOffset: 16)
                }
                
                let iconsAndLabels = (icon:icon, textLabel:textLabel)
                iconsView.append(iconsAndLabels)
                
                if 0 == index { // selected first elemet
                    item.selectedState(icon, textLabel: textLabel)
                }
                
                item.image = nil
                item.title = ""
            }
        }
    }
    
    func createConstraints(view:UIView, container:UIView, size:CGSize, yOffset:CGFloat) {
        
        let constX = NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
        container.addConstraint(constX)
        
        let constY = NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: yOffset)
        container.addConstraint(constY)
        
        let constW = NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: size.width)
        view.addConstraint(constW)
        
        let constH = NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: size.height)
        view.addConstraint(constH)
    }
    
    func createViewContainers() -> NSDictionary {
        
        let containersDict = NSMutableDictionary()
        let itemsCount: Int = tabBar.items!.count as Int - 1
        
        for index in 0...itemsCount {
            let viewContainer = createViewContainer()
            containersDict.setValue(viewContainer, forKey: "container\(index)")
        }
        
        let keys = containersDict.allKeys
        
        var formatString = "H:|-(0)-[container0]"
        for index in 1...itemsCount {
            formatString += "-(0)-[container\(index)(==container0)]"
        }
        formatString += "-(0)-|"
        let constranints = NSLayoutConstraint.constraintsWithVisualFormat(formatString,
            options:NSLayoutFormatOptions.DirectionRightToLeft,
            metrics: nil,
            views: containersDict as [NSObject : AnyObject])
        view.addConstraints(constranints)
        
        return containersDict
    }
    
    func createViewContainer() -> UIView {
        let viewContainer = UIView()
        viewContainer.backgroundColor = UIColor.clearColor() // for test
        viewContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(viewContainer)
        
        // add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
        tapGesture.numberOfTouchesRequired = 1
        viewContainer.addGestureRecognizer(tapGesture)
        
        // add constrains
        let constY = NSLayoutConstraint(item: viewContainer,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        
        view.addConstraint(constY)
        
        let constH = NSLayoutConstraint(item: viewContainer,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: tabBar.frame.size.height)
        viewContainer.addConstraint(constH)
        
        return viewContainer
    }
    
    // MARK: actions
    
    func tapHandler(gesture:UIGestureRecognizer) {
        
        let items = tabBar.items as! [RAMAnimatedTabBarItem]
        
        let currentIndex = gesture.view!.tag
        if selectedIndex != currentIndex {
            let animationItem : RAMAnimatedTabBarItem = items[currentIndex]
            let icon = iconsView[currentIndex].icon
            let textLabel = iconsView[currentIndex].textLabel
            animationItem.playAnimation(icon, textLabel: textLabel)
            
            let deselelectIcon = iconsView[selectedIndex].icon
            let deselelectTextLabel = iconsView[selectedIndex].textLabel
            let deselectItem = items[selectedIndex]
            deselectItem.deselectAnimation(deselelectIcon, textLabel: deselelectTextLabel)
            
            selectedIndex = gesture.view!.tag
        }
    }
    
    func setSelectIndex(#from:Int,to:Int) {
        selectedIndex = to
        let items = tabBar.items as! [RAMAnimatedTabBarItem]
        items[from].deselectAnimation(iconsView[from].icon, textLabel: iconsView[from].textLabel)
        items[to].playAnimation(iconsView[to].icon, textLabel: iconsView[to].textLabel)
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
