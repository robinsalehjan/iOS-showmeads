//
//  AdsFacade.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 19/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

class AdsFacade {
    fileprivate var adService: AdService
    fileprivate var adPersistenceService: AdPersistenceService

    // MARK: - Properties
    static let shared = AdsFacade()

    private init() {
        self.adService = AdService.init(endpoint: Endpoint.adUrl)
        self.adPersistenceService = AdPersistenceService()
    }

    public func fetchAds(completionHandler: @escaping ((_ ads: [AdItem], _ isOffline: Bool) -> Void)) {
        guard Reachability.isConnectedToNetwork() else {
            self.adPersistenceService.fetchFavoriteAds(completionHandler: { (ads) in
                let isOffline = true
                completionHandler(ads, isOffline)
            })
            return
        }

        self.adService.fetchRemote(completionHandler: { [unowned self] (ads, isOffline) in
            // In case the request fails for whatever reason
            // Default to show favorited ads
            guard ads.count > 0 else {
                self.adPersistenceService.fetchFavoriteAds(completionHandler: { (ads) in
                    let isOffline = true
                    completionHandler(ads, isOffline)
                })
                return
            }
            
            let alreadyFavorited: [AdItem] = ads.map {
                if let exists = self.adPersistenceService.exists(ad: $0) { return exists } else { return $0 }
            }

            completionHandler(alreadyFavorited, isOffline)
        })
    }

    public func fetchFavoriteAds(completionHandler: @escaping ((_ ads: [AdItem]) -> Void)) {
        self.adPersistenceService.fetchFavoriteAds(completionHandler: { (ads) in
            completionHandler(ads)
        })
    }

    public func save(ad: AdItem) {
        self.adPersistenceService.save(ad: ad)
    }

    public func remove(ad: AdItem) {
        self.adPersistenceService.remove(ad: ad)
    }
}
