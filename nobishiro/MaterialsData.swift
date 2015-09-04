//
//  MaterialsData.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/4/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct MaterialsData: Decodable {
    let data: [Material]
    let error: String

    static func decode(e: Extractor) -> MaterialsData? {
        let create = { MaterialsData($0) }

        return build(create)(
            e <|| "data",
            e <| "error"
        )
    }
}
