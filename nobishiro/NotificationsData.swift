//
//  NotificationsData.swift
//  nobishiro
//
//  Created by Yuji Fujisaka on 9/9/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct NotificationsData: Decodable {
    let data: [Notification]
    let status: String
  
    static func decode(e: Extractor) -> NotificationsData? {
        let create = { NotificationsData($0) }

        return build(create)(
            e <|| "data",
            e <| "status"
        )
    }
}