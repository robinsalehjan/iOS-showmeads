//
//  AdService.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 10/09/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation

public enum EndpointType {
    case remote, database
}

public protocol AdServiceDataSource: NSObjectProtocol {
    func didUpdate(ads: [AdItem])
}

final class AdService {
    
    // MARK: Public properties
    
    public weak var dataSource: AdServiceDataSource?
    
    // MARK: Private properties
    
    fileprivate var networkService: AdNetworkService
    fileprivate var persistenceService: AdPersistenceService
    
    init(_ networkService: AdNetworkService, _ persistenceService: AdPersistenceService) {
        self.networkService = networkService
        self.persistenceService = persistenceService

        scheduleRequest()
    }
}

// MARK: Public methods

extension AdService {
    
    /// Returns true if there's any ads saved to core data, false otherwise
    
    public func hasSavedAds() -> Bool {
        let ads = persistenceService.fetch(where: nil)
        switch ads.count {
        case let count where count > 0:
            return true
        default:
            return false
        }
    }
    
    // Fetches ads from any given `EndpointType`
    // After retriving the ads it calls the `didUpdate` to notify the implementing delegate
    
    public func fetchAds(endpoint: EndpointType) {
        switch endpoint {
        case .remote:
            networkService.fetch(completionHandler: { [weak self] (response) in
                guard let strongSelf = self else { return }
                switch response {
                case .error(_):
                    let ads = strongSelf.persistenceService.fetch(where: nil)
                    self?.dataSource?.didUpdate(ads: ads)
                case .success(let ads):
                    let filteredAds = strongSelf.persistenceService.updateOrInsert(ads)
                    self?.dataSource?.didUpdate(ads: filteredAds)
                }
            })
        case .database:
            let ads = persistenceService.fetch(where: nil)
            self.dataSource?.didUpdate(ads: ads)
        }
    }
    
    // Fetches the ads from Core Data that has been favorited
    
    public func fetchFavoritedAds() {
        let ads = persistenceService.fetch(where: NSPredicate(format: "isFavorited == true"))
        dataSource?.didUpdate(ads: ads)
    }
    
    // Update the provided fields for any given `Ad` entity in Core Data
    
    public func update(ad: AdItem, price: Int32? = nil, location: String? = nil,
                       title: String? = nil, isFavorited: Bool? = nil) {
        persistenceService.update(ad, price: price, location: location,
                                  title: title, isFavorited: isFavorited)
    }
}

// MARK: Private methods

extension AdService {
    
    /// Sends a GET request to the backend every 5 minutes.
    
    private func scheduleRequest() {
        let scheduledTime = DispatchTime.now() + (60 * 5)
        DispatchQueue.main.asyncAfter(deadline: scheduledTime) { [weak self] in
            self?.fetchAds(endpoint: .remote)
            self?.scheduleRequest()
        }
    }
}
