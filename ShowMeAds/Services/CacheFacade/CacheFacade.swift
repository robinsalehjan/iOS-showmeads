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

final class CacheFacade {
    fileprivate var adImageCacheService = AdImageCacheService()
    
    static let shared = CacheFacade()
    private init() {}
    
    // MARK: Public methods for the cache
    
    public func fetch(cacheType: CacheType, key: String, onCompletion: @escaping (_ data: NSData) -> Void) {
        switch cacheType {
        case .image:
            self.adImageCacheService.fetch(url: key) { (data: NSData) in
                onCompletion(data)
            }
        }
    }
    
    public func evict(cacheType: CacheType, key: String) {
        switch cacheType {
        case .image:
            self.adImageCacheService.evict(url: key)
        }
    }
    
    // MARK: Public methods for the disk cache
    
    public func fetchFromDisk(key: String) -> NSData? {
        guard let data = AdDiskCacheService.shared.fetchFromDisk(key: key) else { return nil }
        return data
    }
    
    public func saveToDisk(key: String, data: NSData) {
        AdDiskCacheService.shared.saveToDisk(key: key, data: data)
    }
    
    public func deleteFromDisk(key: String) {
        AdDiskCacheService.shared.deleteFromDisk(key: key)
    }
}
