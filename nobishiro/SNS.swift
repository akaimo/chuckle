//
//  SNS.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/8/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Social
import Haneke
import Himotoki
import Alamofire

struct SNS {
    static func postToSocial(viewController: UIViewController, forServiceType: String, image: UIImage) {
        let composeView = SLComposeViewController(forServiceType: forServiceType)
        composeView.setInitialText("何が好きでXcode開いてるのにvimでSwift書かないといけないんですかね(激怒)")
        composeView.addImage(image)
        viewController.presentViewController(composeView, animated: true, completion: nil)
    }
    static func postToLINE(image: UIImage) {
        let pasteBoard = UIPasteboard.pasteboardWithUniqueName()
        pasteBoard.setData(UIImagePNGRepresentation(image), forPasteboardType: "chuckle.png")
        let lineURLString = "line://msg/image/\(pasteBoard.name)"
        UIApplication.sharedApplication().openURL(NSURL(string: lineURLString)!)
    }
    static func shareWithSNS(viewController: UIViewController, sns: SNSType, workID: Int) {
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
                            self.postToSocial(viewController, forServiceType: SLServiceTypeTwitter, image: image)
                        case .Facebook:
                            println("type: facebook")
                            self.postToSocial(viewController, forServiceType: SLServiceTypeFacebook, image: image)
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
}

enum SNSType {
    case Twitter
    case Facebook
    case LINE
}