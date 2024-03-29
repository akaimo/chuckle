//
//  FavoritesData.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/7/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct FavoritesData: Decodable {
    let data: [Favorite]
    let status: String

    static func decode(e: Extractor) -> FavoritesData? {
        let create = { FavoritesData($0) }

        return build(create)(
            e <|| "data",
            e <| "status"
        )
    }
}
