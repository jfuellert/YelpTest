//
//  RestaurantResultsModel.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-24.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import Foundation

struct RestaurantResultsModel: Decodable {

    // MARK: - Properties
    var total: Int
    var restaurants: [RestaurantModel]
    
    enum CodingKeys: String, CodingKey {
        case total
        case restaurants = "businesses"
    }
}
