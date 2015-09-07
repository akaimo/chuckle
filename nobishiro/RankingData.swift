//
//  RankingData.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/7/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct RankingData: Decodable {
    let data: [Work]
    let status: String

    static func decode(e: Extractor) -> RankingData? {
        let create = { RankingData($0) }

        return build(create)(
            e <|| "data",
            e <| "status"
        )
    }
}