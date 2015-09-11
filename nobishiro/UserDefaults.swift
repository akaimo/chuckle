//
//  UserDefaults.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/9/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation

struct UserDefaults {
    static func platformName() -> String {
        var size: size_t = 0;
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = UnsafeMutablePointer<CChar>(malloc(size))
        sysctlbyname("hw.machine", machine, &size, nil, 0)
        var platformName = NSString(CString: machine, encoding: NSUTF8StringEncoding)
        free(machine)

        return platformName! as String
    }

    static func getUserID() -> Int {
        let ud = NSUserDefaults.standardUserDefaults()
        if let uid:AnyObject = ud.objectForKey("userID") {
            println("userID return \(uid)")
            return uid as! Int
        }else{
            println("userID return 仮の1")
            return 1
        }
        
    }
}