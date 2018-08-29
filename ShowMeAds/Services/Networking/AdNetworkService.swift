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
    fileprivate let imageEndpoint = "https://images.finncdn.no/dynamic/480x360c/"
    
    // MARK: - Public
    /** Send an GET request to the API
    */
    
    func fetchRemote(completionHandler: @escaping ((Result<[AdItem], Error>) -> Void)) {
        guard let endpoint = URL.isValid(self.endpoint) else {
            debugPrint("[ERROR]: Could not construct a valid URL instance with the given url: \(self.endpoint)")
            completionHandler(Result.error(Error.invalidURL))
            return
        }
        
        guard Reachability.isConnectedToNetwork() else {
            completionHandler(Result.error(Error.networkUnavailable))
            return
        }
        
        URLSession.shared.dataTask(with: endpoint) { [weak self] (data, response, error) in
            guard error == nil else {
                completionHandler(Result.error(.networkUnavailable))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completionHandler(Result.error(.invalidResponse))
                return
            }
            
            switch response.statusCode {
            case 200:
                guard let dictionary = self?.serializeToDictionary(data) else { return }
                guard let ads = self?.parse(dictionary) else { return }
                completionHandler(Result.success(ads))
            default:
                debugPrint("[INFO]: Not supported status code: \(response.statusCode) headers: \(response.allHeaderFields)")
                completionHandler(Result.error(.invalidStatusCode))
            }
        }.resume()
    }
}

// MARK: - Private methods

extension AdNetworkService {
    /// Serialize the response into a JSON object
    
    private func serializeToDictionary(_ data: Data?) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        if let responseData = data {
            let json = try? JSONSerialization.jsonObject(with: responseData, options: [])
            if let dictionaryData = json as? [String: Any] {
                dictionary = dictionaryData
            }
        }
        return dictionary
    }
    
    /// Deserialize the JSON object into an ad
    
    private func parse(_ dictionary: [String: Any]) -> [AdItem] {
        var ads: [AdItem] = []
        
        if let items = dictionary["items"] as? [Any] {
            for item in items {
                var ad = AdItem()
                
                if let itemDictionary = item as? [String: Any] {
                    if let imageDictionary = itemDictionary["image"] as? [String: Any] {
                        if let imageUrl = imageDictionary["url"] as? String {
                            ad.imageUrl = "\(imageEndpoint)\(imageUrl)"
                        }
                    }
                    if let priceDictionary = itemDictionary["price"] as? [String: Any] {
                        if let price = priceDictionary["value"] as? Int32 {
                            ad.price = price
                        }
                    }
                    if let location = itemDictionary["location"] as? String {
                        ad.location = location
                    }
                    if let description = itemDictionary["description"] as? String {
                        ad.title = description
                    }
                }
                ads.append(ad)
            }
        }
        return ads
    }
}
