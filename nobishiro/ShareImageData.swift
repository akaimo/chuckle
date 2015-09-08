//
//  ShareImageData.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/8/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct ShareImageData: Decodable  {
    let data: String
    let status: String

    static func decode(e: Extractor) -> ShareImageData? {
        let create = { ShareImageData($0) }

        return build(create)(
            e <| "data",
            e <| "status"
        )
    }
}