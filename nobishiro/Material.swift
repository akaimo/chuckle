//
//  Material.swift
//  nobishiro
//
//  Created by S-Shimotori on 9/4/15.
//  Copyright (c) 2015 akaimo. All rights reserved.
//

import Foundation
import Himotoki

struct Material: Decodable {
    let materialId: Int
    let url: String

    static func decode(e: Extractor) -> Material? {
        let create = { Material($0) }

        return build(create)(
            e <| "material_id",
            e <| "url"
        )
    }

}
