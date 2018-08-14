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
    
    fileprivate var adRemoteService = AdRemoteService.init(endpoint: Endpoint.adUrl)
    fileprivate var adCacheService = AdCacheService.shared
    fileprivate var adPersistenceService = AdPersistenceService()
    
    static let shared = AdsFacade()

    private init() {}
    
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

        self.adRemoteService.fetchRemote(completionHandler: { (ads, isOffline) in
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
            
            // MARK: TODO - Fetch images from remote source and add to memory cache
            
            completionHandler(alreadyFavorited, isOffline)
        })
    }
    
    /** Fetch ads from Core Data
     */
    public func fetchFavoriteAds(completionHandler: @escaping ((_ ads: [AdItem]) -> Void)) {
        
        // MARK: TODO - Fetch ads from disk cache
        self.adPersistenceService.fetchFavoriteAds(completionHandler: { (ads) in
            completionHandler(ads)
        })
    }
    
    /** Insert an ad into Core Data
    */
    public func insert(ad: AdItem) {
        guard !ad.imageUrl.isEmpty && !ad.location.isEmpty && !ad.title.isEmpty else { return }
        
        // MARK: TODO - Add to memory cache
        // MARK: TODO - Add to disk cache
        
        self.adPersistenceService.insert(ad: ad)
    }
    
    /** Delete an ad from Core Data
     */
    public func delete(ad: AdItem) {
        
        // MARK: TODO - Evict from memory cache
        // MARK: TODO - Evict from disk cache
        
        self.adPersistenceService.delete(ad: ad)
    }
}
