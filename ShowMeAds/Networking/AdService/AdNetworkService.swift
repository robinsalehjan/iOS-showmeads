//
//  AdService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation

/** Provides an API to interact with the remote API
 */
final class AdNetworkService {

    // MARK: - Properties
    
    fileprivate var endpoint = "https://gist.githubusercontent.com/3lvis/3799feea005ed49942dcb56386ecec2b/raw/63249144485884d279d55f4f3907e37098f55c74/discover.json"
    fileprivate var adProcessorService: AdProcessorService = AdProcessorService()
    
    // MARK: - Public
    /** Send an GET request to the API
    */
    func fetchRemote(completionHandler: @escaping ((Result<[AdItem], Error>) -> Void)) {
        guard Reachability.isConnectedToNetwork() else {
            completionHandler(Result.error(Error.networkUnavailable))
            return
        }
        
        guard let endpoint = URL.isValid(self.endpoint) else {
            debugPrint("[ERROR]: Could not construct a valid URL instance with the given url: \(self.endpoint)")
            completionHandler(Result.error(Error.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
            var ads: [AdItem] = []
            
            guard error == nil else {
                debugPrint("[INFO]: Failed while fetching from remote source")
                completionHandler(Result.error(.networkUnavailable))
                return
            }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    ads = self.adProcessorService.parseData(data: data)
                    completionHandler(Result.success(ads))
                default:
                    debugPrint("[INFO]: Not supported status code: \(response.statusCode)" +
                        " headers: \(response.allHeaderFields)")
                    completionHandler(Result.error(.invalidStatusCode))
                }
            }
        }.resume()
    }
}
