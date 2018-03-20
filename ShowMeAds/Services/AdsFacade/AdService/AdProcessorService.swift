//
//  AdProcessorService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

final class AdProcessorService {

    // MARK: - Public functions

    func parseData(data: Data?) -> [AdItem] {
        let dictionary = serializeToDictionary(data: data)
        let parsedAds: [AdItem] = parse(dictionary: dictionary)
        return parsedAds
    }

    // MARK: - Private functions

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

    private func parse(dictionary: [String: Any]) -> [AdItem] {
        var ads: [AdItem] = []

        if let items = dictionary["items"] as? [Any] {
            for item in items {
                var ad = AdItem()

                if let itemDictionary = item as? [String: Any] {
                    if let imageDictionary = itemDictionary["image"] as? [String: Any] {
                        if let imageUrl = imageDictionary["url"] as? String {
                            ad.imageUrl = "\(Endpoint.imageBaseUrl)\(imageUrl)"
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
