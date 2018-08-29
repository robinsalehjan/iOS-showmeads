//
//  CacheFacade.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 15/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation

enum CacheType: String {
    case image
}

/// Client API to interact with different caching services

final class AdCacheService {
    fileprivate var adImageCacheService = AdImageCacheService()
    
    static let shared = AdCacheService()
    private init() {}
    
    // MARK: Public methods for the cache
    
    /// Retrieve a value associated for a given key in the specified cache
    
    public func fetch(cacheType: CacheType, key: String, onCompletion: @escaping (_ data: NSData) -> Void) {
        switch cacheType {
        case .image:
            self.adImageCacheService.fetch(url: key) { (data: NSData) in
                onCompletion(data)
            }
        }
    }
    
    /// Remove a value associated with an given key in the specified cache
    
    public func remove(cacheType: CacheType, key: String) {
        switch cacheType {
        case .image:
            self.adImageCacheService.remove(url: key)
        }
    }
    
    /// Remove all values from the cache
    
    public func removeAll(cacheType: CacheType) {
        switch cacheType {
        case .image:
            self.adImageCacheService.removeAll()
        }
    }
    
    // MARK: Public methods for the disk cache
    
    /// Retrieve a value associated for an given key from disk
    
    public func fetchFromDisk(key: String) -> NSData? {
        guard let data = AdDiskCacheService.shared.fetchFromDisk(key: key) else { return nil }
        return data
    }
    
    /// Save the value associated with the
    
    public func saveToDisk(key: String, data: NSData) {
        AdDiskCacheService.shared.saveToDisk(key: key, data: data)
    }
    
    /// Delete the value associated with the given `key` from disk
    
    public func deleteFromDisk(key: String) {
        AdDiskCacheService.shared.deleteFromDisk(key: key)
    }
    
    /// Deletes all key-value pairs from disk
    
    public func clearDisk() {
        AdDiskCacheService.shared.clearDisk()
    }
}
