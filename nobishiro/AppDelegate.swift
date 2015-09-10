//
//  AppDelegate.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/03.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var notificationsBadgeValue = 0


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
      if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
        // iOS8以上
        let apnsTypes = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        
        let notiSettings = UIUserNotificationSettings(forTypes:apnsTypes, categories:nil)
        application.registerUserNotificationSettings(notiSettings)
        application.registerForRemoteNotifications()
        
      } else{
        // iOS7以前
        application.registerForRemoteNotificationTypes( UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert )
      }
      
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
  
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
      let deviceTokenString = "\(deviceToken)".stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString:"<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
      println("deviceToken = \(deviceTokenString)")
      registUser(deviceTokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
      println("Failed to get token, error: \(error)")
      registUser("failedToGetDeviceToken")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
       // println("application:didReceiveRemoteNotification: " + userInfo.description)
        notificationsBadgeValue += 1
        setBadgeValue(String(notificationsBadgeValue))
    }
    
    func resetBadgeValue(){
        notificationsBadgeValue = 0
        setBadgeValue(nil)
    }
    
    func setBadgeValue(badgeValue: String?){
        let rootViewController = self.window?.rootViewController as! UITabBarController!
        let tabArray = rootViewController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(3) as! UITabBarItem
        if let badgeValueString = badgeValue {
            tabItem.badgeValue = badgeValueString
        }else{
            tabItem.badgeValue = nil
        }
    }
    
    func registUser(deviceTokenString: String){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let savedUserID: AnyObject = userDefaults.objectForKey("userID") { // IDを端末内に保存済みなら
            println("userID = \(savedUserID)")
            if let savedDeviceToken: AnyObject = userDefaults.objectForKey("deviceToken") {
                if savedDeviceToken as! String != deviceTokenString {
                    //デバイストークンが変化していたら、idそのままでトークンだけ再登録
                    Alamofire.request(.PUT, "http://yuji.website:3001/api/register/\(savedUserID as! NSNumber)?device_token="+deviceTokenString, parameters: nil, encoding: .JSON).responseJSON{ request, response, JSON, error in
                        if let responseJson = JSON as? NSDictionary {
                            println("deviceToken updated")
                            userDefaults.setObject(deviceTokenString, forKey: "deviceToken")
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }else{
            println("ユーザー新規登録")
            //デバイストークンをサーバーに登録して、idを受け取る
            Alamofire.request(.GET, "http://yuji.website:3001/api/register?screen_name=testuser&device_token="+deviceTokenString, parameters: nil, encoding: .JSON).responseJSON{ request, response, JSON, error in
                if let responseJson = JSON as? NSDictionary {
                    userDefaults.setObject(deviceTokenString, forKey: "deviceToken")
                    userDefaults.setObject(responseJson.objectForKey("status")!, forKey: "userID")
                    userDefaults.synchronize()
                    print("ユーザー登録:成功 userID = ")
                    println(userDefaults.objectForKey("userID"))
                }else{
                    println("ユーザー登録:失敗")
                    println(error)
                }
            }
        }

    }

}

