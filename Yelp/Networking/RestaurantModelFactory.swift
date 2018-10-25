//
//  RestaurantModelFactory.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-23.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import UIKit

class RestaurantModelFactory: NSObject {
    
    // MARK: - Constants
    static private let kSearchResultCount = 10
    
    // MARK: - Fetch
    @discardableResult public static func fetchRestaurantsWithTerm(_ term: String, completion: @escaping (RestaurantResultsModel?, Error?) -> ()) -> URLSessionDataTask? {
        
        return request(.GET, endpoint: "v3/businesses/search?limit=\(kSearchResultCount)&term=\(term)", body: nil, headers: [:]) { (statusCode, error, data) in
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let result = try? JSONDecoder().decode(RestaurantResultsModel.self, from: data)
            completion(result, error)
        }
    }
}

// MARK: - Authenticate
extension RestaurantModelFactory {
    
    @discardableResult public static func authenticate(_ completion: @escaping (String?, Error?) -> ()) -> URLSessionDataTask? {
        
        let body = ["client_id": kClientID,
                    "client_secret": kAPIKey,
                    "grant_type": "client_credentials"]
        
        return rawRequest(.POST, endpoint: "oauth2/token", body: body, headers: [:]) { (statusCode, error, data) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil, error)
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
    static private let kServerURL                     = "https://api.yelp.com/"
    static private let kClientID                      = "kAvzDzByPKICyHPupNUqCg"
    static private let kAPIKey                        = "K0XM1oNmhguLAH9wStRSGTBp8Jw1LEyPQ_gNXK42W91Ty7MVKPraXjHseAFfwNpptd-WKvfxI8eisJHfQYHJuxB2uNHpqOrthbnce7XzpaTxiGq8xaAwyKKgCRDRW3Yx"
    static private let kAuthorizationTokenKey         = "Authorization"
    static private let kAuthorizationTokenValuePrefix = "Bearer"
    static private let kContentTypeKey                = "Content-Type"
    static private let kContentTypeValue              = "application/x-www-form-urlencoded, application/json"
    
    // MARK: - Requests
    private static func session(_ headers: [String: Any]) -> URLSession {
        
        let sessionConfiguration         = URLSessionConfiguration.default
        sessionConfiguration.httpShouldSetCookies = true
        var modifiedHeaders              = headers
        modifiedHeaders[kContentTypeKey] = kContentTypeValue
        
        if let authenticationToken = PersistentStore.authenticationToken {
            modifiedHeaders[kAuthorizationTokenKey] = "\(kAuthorizationTokenValuePrefix) \(authenticationToken)"
        }
                
        sessionConfiguration.httpAdditionalHeaders = modifiedHeaders

        return URLSession(configuration: sessionConfiguration)
    }
    
    @discardableResult static fileprivate func request(_ requestType: RequestType = .GET, endpoint: String, body: [String: Any]? = [:], headers: [String: Any] = [:], completion: @escaping (Int, Error?, Data?) ->()) -> URLSessionDataTask? {

        guard PersistentStore.authenticationToken?.isEmpty == false else {
            return authenticate({ (_, error) in
                return rawRequest(requestType, endpoint: endpoint, body: body, headers: headers, completion: completion)
            })
        }
        
        return rawRequest(requestType, endpoint: endpoint, body: body, headers: headers, completion: completion)
    }
    
    @discardableResult static private func rawRequest(_ requestType: RequestType = .GET, endpoint: String, body: [String: Any]? = [:], headers: [String: Any] = [:], completion: @escaping (Int, Error?, Data?) ->()) -> URLSessionDataTask? {
        
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
