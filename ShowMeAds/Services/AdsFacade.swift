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
    fileprivate var adRemoteService = AdNetworkService()
    fileprivate var adPersistenceService = AdPersistenceService()
    
    static let shared = AdsFacade()
    private init() {}
    
    // MARK: - Public
    
    /** Fetch ads from the remote API
     */
    public func fetchAds(endpoint: EndpointType, completionHandler: @escaping ((Result<[AdItem], Error>) -> Void)) {
        switch endpoint {
        case .remote:
            adRemoteService.fetchRemote(completionHandler: { [weak self] (response) in
                switch response {
                case .success(let ads):
                    let alreadyFavorited: [AdItem] = ads.map {
                        if let existingAd = self?.adPersistenceService.exists($0) {
                            self?.adPersistenceService.update(existingAd)
                            return existingAd
                        } else {
                            self?.adPersistenceService.insert($0)
                            return $0
                        }
                    }
                    completionHandler(Result.success(alreadyFavorited))
                case .error(let error):
                    
                    completionHandler(Result.error(error))
                }
            })
        case .database:
            let ads = adPersistenceService.fetch(where: nil)
            completionHandler(Result.success(ads))
        }
    }
    
    /** Insert an ad into Core Data
     Saves the Ad image data to disk
    */
    public func insert(_ ad: AdItem) {
        guard !ad.imageUrl.isEmpty && !ad.location.isEmpty && !ad.title.isEmpty else { return }
        
        let key = ad.imageUrl
        CacheFacade.shared.fetch(cacheType: .image, key: key) { (data: NSData) in
            CacheFacade.shared.saveToDisk(key: key, data: data)
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
        CacheFacade.shared.deleteFromDisk(key: key)
        adPersistenceService.delete(ad)
    }
}
