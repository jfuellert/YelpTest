//
//  ReviewModel.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-26.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import UIKit

struct ReviewModel: Decodable {
    
    // MARK: - Properties
    var identifier: String?
    var rating: Int?
    var text: String?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case rating
        case text
    }
}
