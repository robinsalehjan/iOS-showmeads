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
final class AdService {

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
        guard let url =  URL.init(string: self.endpoint) else {
            fatalError("[ERROR]: The URL string: \(self.endpoint) is not valid")
        }
        guard let endpoint = url as URL? else {
            fatalError("[ERROR]: Could not construct a URL instance with the given url: \(url)")
        }
        
        URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
            var ads: [AdItem] = []
            var isOffline = false

            guard error == nil else {
                print("[INFO]: Failed while fetching from remote source")
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
                    print("[INFO]: Not supported status code: \(response.statusCode)" +
                        " headers: \(response.allHeaderFields)")
                    completionHandler(ads, isOffline)
                }
            }
        }.resume()
    }
}
