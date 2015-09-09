//
//  Notification.swift
//  nobishiro
//
//  Created by Yuji Fujisaka on 9/9/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct Notification: Decodable {
    let workId: Int
    let title: String
    let imageUrl: String

    static func decode(e: Extractor) -> Notification? {
        let create = { Notification($0) }
    
        return build(create)(
            e <| "work_id",
            e <| "title",
            e <| "image_url"
        )
    }
}
