//
//  AdProcessorService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

/** Provides an API to parse and serialize responses from the remote API into AdItem instances
 */
final class AdProcessorService {
    
    // MARK: - Properties
    fileprivate let imageBaseUrl = "https://images.finncdn.no/dynamic/480x360c/"
    
    // MARK: - Public
    /** Parse an Data response from the API to an list of ads
    */
    func parseData(data: Data?) -> [AdItem] {
        let dictionary = serializeToDictionary(data: data)
        let parsedAds: [AdItem] = parse(dictionary: dictionary)
        return parsedAds
    }

    // MARK: - Private
    
    /** Serialize the response into a JSON object
     */
    private func serializeToDictionary(data: Data?) -> [String: Any] {
        var dictionary: [String: Any] = [:]

        if let responseData = data {
            let json = try? JSONSerialization.jsonObject(with: responseData, options: [])
            if let dictionaryData = json as? [String: Any] {
                dictionary = dictionaryData
            }
        }
        return dictionary
    }
    
    /** Deserialize the JSON object into an ad
     */
    private func parse(dictionary: [String: Any]) -> [AdItem] {
        var ads: [AdItem] = []

        if let items = dictionary["items"] as? [Any] {
            for item in items {
                var ad = AdItem()

                if let itemDictionary = item as? [String: Any] {
                    if let imageDictionary = itemDictionary["image"] as? [String: Any] {
                        if let imageUrl = imageDictionary["url"] as? String {
                            ad.imageUrl = "\(imageBaseUrl)\(imageUrl)"
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
