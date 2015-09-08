//
//  Works.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/4/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct Work: Decodable {
    let workId: Int
    let userId: Int
    let favoriteCount: Int
    let title: String
    let materials: [Material]

    static func decode(e: Extractor) -> Work? {
        let create = { Work($0) }

        return build(create)(
            e <| "work_id",
            e <| "user_id",
            e <| "favorite_count",
            e <| "title",
            e <|| "materials"
        )
    }
}
