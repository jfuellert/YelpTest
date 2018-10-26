//
//  RestaurantModelFactory.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-23.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import CoreLocation

class RestaurantModelFactory: NSObject {
    
    // MARK: - Constants
    static private let kSearchResultCount = 10
    
    // MARK: - Fetch
    @discardableResult public static func fetchRestaurantsWithTerm(_ term: String, coordinates: CLLocationCoordinate2D, completion: @escaping (RestaurantResultsModel?, Error?) -> ()) -> URLSessionDataTask? {
        
        return request(.GET, endpoint: "businesses/search?limit=\(kSearchResultCount)&term=\(term)&latitude=\(coordinates.latitude)&longitude=\(coordinates.longitude)", body: nil, headers: [:]) { (statusCode, error, data) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let result = try? JSONDecoder().decode(RestaurantResultsModel.self, from: data)
            DispatchQueue.main.async {
                completion(result, error)
            }
        }
    }
}

// MARK: - Utility
extension RestaurantModelFactory {
    
    fileprivate enum RequestType: String {
        case GET
        case POST
    }
    
    //MARK: Constants
    static private let kServerURL                     = "https://api.yelp.com/v3/"
    static private let kAPIKey                        = "K0XM1oNmhguLAH9wStRSGTBp8Jw1LEyPQ_gNXK42W91Ty7MVKPraXjHseAFfwNpptd-WKvfxI8eisJHfQYHJuxB2uNHpqOrthbnce7XzpaTxiGq8xaAwyKKgCRDRW3Yx"
    static private let kAuthorizationTokenKey         = "Authorization"
    static private let kAuthorizationTokenValuePrefix = "Bearer"
    static private let kContentTypeKey                = "Content-Type"
    static private let kContentTypeValue              = "application/json"

    // MARK: - Requests
    static private func session(_ headers: [String: String]) -> URLSession {
        
        let sessionConfiguration                   = URLSessionConfiguration.default
        var modifiedHeaders                        = headers
        modifiedHeaders[kContentTypeKey]           = kContentTypeValue
        modifiedHeaders[kAuthorizationTokenKey]    = "\(kAuthorizationTokenValuePrefix) \(kAPIKey)"
        sessionConfiguration.httpAdditionalHeaders = modifiedHeaders

        return URLSession(configuration: sessionConfiguration)
    }
    
    @discardableResult static private func request(_ requestType: RequestType = .GET, endpoint: String, body: [String: Any]? = [:], headers: [String: String] = [:], completion: @escaping (Int, Error?, Data?) ->()) -> URLSessionDataTask? {
        
        guard let url = URL(string: kServerURL + endpoint) else {
            return nil
        }
        
        var request        = URLRequest(url: url)
        request.httpMethod = requestType.rawValue.lowercased()
        if let body = body, body.count > 0 {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let dataTask = session(headers).dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(NSNotFound , error, nil)
                return
            }
            
            guard let data = data else {
                completion(httpResponse.statusCode, error, nil)
                return
            }
            
            completion(httpResponse.statusCode, nil, data)
        }
        
        defer {
            dataTask.resume()
        }
        
        return dataTask
    }
}
