//
//  AdsFacade.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 19/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

/** Abstraction that provides a simple interface to use and interact with the AdService and AdPersistenceService
 */
class AdsFacade {
    
    // MARK: - Properties
    
    fileprivate var adService: AdService
    fileprivate var adPersistenceService: AdPersistenceService
    
    static let shared = AdsFacade()

    private init() {
        self.adService = AdService.init(endpoint: Endpoint.adUrl)
        self.adPersistenceService = AdPersistenceService()
    }
    
    // MARK: - Public
    
    /** Fetch ads from the remote API
     */
    public func fetchAds(completionHandler: @escaping ((_ ads: [AdItem], _ isOffline: Bool) -> Void)) {
        guard Reachability.isConnectedToNetwork() else {
            self.adPersistenceService.fetchFavoriteAds(completionHandler: { (ads) in
                let isOffline = true
                completionHandler(ads, isOffline)
            })
            return
        }

        self.adService.fetchRemote(completionHandler: { (ads, isOffline) in
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
    
    /** Fetch ads from Core Data
     */
    public func fetchFavoriteAds(completionHandler: @escaping ((_ ads: [AdItem]) -> Void)) {
        self.adPersistenceService.fetchFavoriteAds(completionHandler: { (ads) in
            completionHandler(ads)
        })
    }
    
    /** Insert an ad into Core Data
    */
    public func insert(ad: AdItem) {
        if ad.imageUrl == nil { return }
        if ad.location == nil { return }
        if ad.title == nil    { return }
        self.adPersistenceService.insert(ad: ad)
    }
    
    /** Delete an ad from Core Data
     */
    public func delete(ad: AdItem) {
        self.adPersistenceService.delete(ad: ad)
    }
}
