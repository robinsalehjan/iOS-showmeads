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
    
    // MARK: Public methods
    
    public func fetchFromCache(cacheType: CacheType, id: String, onCompletion: @escaping (_ data: NSData) -> Void) {
        switch cacheType {
        case .image:
            self.adImageCacheService.fetchFromCache(url: id) { (data) in
                onCompletion(data)
            }
        }
    }
}
