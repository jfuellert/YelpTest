//
//  RestaurantModel.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-23.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import Foundation

struct RestaurantModel: Decodable {

    // MARK: - Properties
    var identifier: String?
    var name: String?
    var imageUrlString: String?
    var URLString: String?
    var location: LocationModel?
    var coordinates: CoordinatesModel?
    
    enum CodingKeys: String, CodingKey {
        case identifier     = "id"
        case name
        case coordinates
        case location       = "location"
        case imageUrlString = "image_url"
        case URLString      = "url"
    }
}

struct LocationModel: Decodable {
    
    // MARK: - Properties
    var city: String?
    var country: String?
    var address1: String?
    var address2: String?
    var address3: String?
    var zip_code: String?
}

struct CoordinatesModel: Decodable {
    
    // MARK: - Properties
    var latitude: Double?
    var longitude: Double?
}
