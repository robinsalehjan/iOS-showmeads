//
//  AdService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation

enum Resource {
    case endpoint
    case imageBaseUrl
}

enum Endpoint: String {
    case url = "https://gist.githubusercontent.com/3lvis/3799feea005ed49942dcb56386ecec2b/raw/63249144485884d279d55f4f3907e37098f55c74/discover.json"
    case imageBaseUrl = "https://images.finncdn.no/dynamic/480x360c/"
    
    static func forResource(type: Resource) -> String {
        switch type {
        case .endpoint:
            return Endpoint.url.rawValue
            
        case .imageBaseUrl:
            return Endpoint.imageBaseUrl.rawValue
        }
    }
}

/** Provides an API to interact with the remote API
 */
final class AdRemoteService {

    // MARK: - Properties
    
    fileprivate var endpoint: String
    fileprivate var adProcessorService: AdProcessorService

    init(endpoint: String) {
        self.endpoint = endpoint
        self.adProcessorService = AdProcessorService.init()
    }
    
    // MARK: - Public
    /** Send an GET request to the API
    */
    func fetchRemote(completionHandler: @escaping ((_ ads: [AdItem], _ isOffline: Bool) -> Void)) {
        guard let endpoint = URL.isValid(self.endpoint) else {
            debugPrint("[ERROR]: Could not construct a valid URL instance with the given url: \(self.endpoint)")
            return
        }
        
        URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
            var ads: [AdItem] = []
            var isOffline = false

            guard error == nil else {
                debugPrint("[INFO]: Failed while fetching from remote source")
                isOffline = true
                completionHandler(ads, isOffline)
                return
            }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    ads = self.adProcessorService.parseData(data: data)
                    completionHandler(ads, isOffline)
                default:
                    debugPrint("[INFO]: Not supported status code: \(response.statusCode)" +
                        " headers: \(response.allHeaderFields)")
                    completionHandler(ads, isOffline)
                }
            }
        }.resume()
    }
}
