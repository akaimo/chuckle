//
//  WorksData.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/4/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct WorksData: Decodable {
    let data: [Work]
    let status: String
    let next: String

    static func decode(e: Extractor) -> WorksData? {
        let create = { WorksData($0) }

        return build(create)(
            e <|| "data",
            e <| "status",
            e <| "next"
        )
    }
}