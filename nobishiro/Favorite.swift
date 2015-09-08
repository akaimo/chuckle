//
//  Favorite.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/7/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct Favorite: Decodable {
    let workId: Int

    static func decode(e: Extractor) -> Favorite? {
        let create = { Favorite(workId: $0) }

        return build(create)(
            e <| "work_id"
        )
    }
}
