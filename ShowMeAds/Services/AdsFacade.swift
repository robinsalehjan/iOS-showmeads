//
//  AdsFacade.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 19/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit


enum EndpointType {
    case remote
    case database
}

/** Abstraction that provides a simple interface to use and interact with the AdService and AdPersistenceService
 */
class AdsFacade {
    
    // MARK: - Properties
    fileprivate var adPersistenceService = AdPersistenceService()
    fileprivate var adImageCacheService = AdImageCacheService()
    fileprivate var adDiskCacheService = AdDiskCacheService()
    
    static let shared = AdsFacade()
    private init() {}
    
    // MARK: - Public
    
    /** Insert an ad into Core Data
     Saves the Ad image data to disk
    */
    public func insert(_ ad: AdItem) {
        guard !ad.imageUrl.isEmpty && !ad.location.isEmpty && !ad.title.isEmpty else { return }
        
        let url = ad.imageUrl
        adImageCacheService.fetch(url: url) { [weak self] (data) in
            self?.adDiskCacheService.saveToDisk(key: url, data: data)
        }
        
        // Make sure the item isn't already favorited
        adPersistenceService.insert(ad)
    }
    
    public func update(_ ad: AdItem) {
        guard !ad.imageUrl.isEmpty && !ad.location.isEmpty && !ad.title.isEmpty else { return }
        adPersistenceService.update(ad)
    }
    
    /** Delete an ad from Core Data
     Removes any related data from the disk cache
     */
    public func delete(_ ad: AdItem) {
        let key = ad.imageUrl
        adDiskCacheService.deleteFromDisk(key: key)
        adPersistenceService.delete(ad)
    }
}
