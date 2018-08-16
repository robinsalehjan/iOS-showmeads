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
    fileprivate var adPersistenceService = AdPersistenceService()
    
    static let shared = AdsFacade()

    private init() {}
    
    // MARK: - Public
    
    /** Fetch ads from the remote API
     */
    public func fetchAds(completionHandler: @escaping ((_ ads: [AdItem], _ isOffline: Bool) -> Void)) {
        guard Reachability.isConnectedToNetwork() else {
            fetchFavoriteAds { (ads) in
                let isOffline = true
                completionHandler(ads, isOffline)
            }
            return
        }

        self.adRemoteService.fetchRemote(completionHandler: { [unowned self] (ads, isOffline) in
            // In case the request fails for whatever reason
            // Default to show favorited ads
            guard ads.count > 0 else {
                self.fetchFavoriteAds(completionHandler: { (ads) in
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
        
        // Load into cache
        
        self.adPersistenceService.fetchFavoriteAds(completionHandler: { (ads) in
            completionHandler(ads)
        })
    }
    
    /** Insert an ad into Core Data
     Saves the Ad image data to disk
    */
    public func insert(ad: AdItem) {
        guard !ad.imageUrl.isEmpty && !ad.location.isEmpty && !ad.title.isEmpty else { return }
        
        let key = ad.imageUrl
        CacheFacade.shared.fetch(cacheType: .image, key: key) { (data: NSData) in
            CacheFacade.shared.saveToDisk(key: key, data: data)
        }
        
        self.adPersistenceService.insert(ad: ad)
    }
    
    /** Delete an ad from Core Data
     Evicts the image data for the related Ad from cache and deletes it from the disk.
     */
    public func delete(ad: AdItem) {
        let key = ad.imageUrl
        CacheFacade.shared.evict(cacheType: .image, key: key)
        CacheFacade.shared.deleteFromDisk(key: key)
        
        self.adPersistenceService.delete(ad: ad)
    }
}
