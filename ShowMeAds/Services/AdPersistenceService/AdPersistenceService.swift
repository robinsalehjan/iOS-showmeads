//
//  AdPersistenceService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 19/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import CoreData

/** Provides an API to interact with Core Data
 */
class AdPersistenceService {
    
    // MARK: Public
    
    /** Fetch ads that matches the given predicate
     */
    
    func fetchAds(where predicate: NSPredicate?) -> [AdItem] {
        var ads: [AdItem] = []
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        request.predicate = predicate
        
        do {
            let result = try backgroundContext.fetch(request)
            if let objects = result as? [Ads] {
                ads = objects.map { $0.convertToAdItem() }
            }
        } catch {
            debugPrint("[ERROR]: Failed to fetch data from CoreData: \(error)")
        }
        
        return ads
    }
    
    /** Insert an ad into Core Data
     */
    
    @discardableResult
    func insert(ad: AdItem) -> Bool {
        guard exists(ad: ad) == nil else { return false }
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Ads", in: backgroundContext) else { return false}
        
        let newAd = Ads.init(entity: entity, insertInto: backgroundContext)
        newAd.setValue(ad.imageUrl, forKey: "imageUrl")
        newAd.setValue(ad.price, forKey: "price")
        newAd.setValue(ad.location, forKey: "location")
        newAd.setValue(ad.title, forKey: "title")
        newAd.setValue(ad.isFavorited, forKey: "isFavorited")

        do {
            try backgroundContext.save()
        } catch {
            debugPrint("[ERROR]: Did not manage to save" +
                " objectID: \(newAd.objectID)" +
                " imageUrl: \(ad.imageUrl)" +
                " price: \(ad.price)" +
                " location: \(ad.location)" +
                " title: \(ad.title)")
        }
        
        return true
    }
    
    /** Delete an ad from Core Data
     */
    
    @discardableResult
    func delete(ad: AdItem) -> Bool {
        guard exists(ad: ad) != nil else { return false }
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        fetchRequest.predicate = NSPredicate(format: "imageUrl ==[c] %@", ad.imageUrl)
        
        do {
            let results = try backgroundContext.fetch(fetchRequest)
            if let ads = results as? [Ads] {
                for ad in ads {
                    backgroundContext.delete(ad)
                }
            }
            try backgroundContext.save()
        } catch {
            debugPrint("[ERROR]: Failed to delete data from CoreData, error: \(error)")
        }
        
        return true
    }
    
    /// Update an record that is saved to Core Data
    
    @discardableResult
    func update(newAd: AdItem) -> Bool {
        guard let ad = exists(ad: newAd) else { return false }
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        fetchRequest.predicate = NSPredicate(format: "imageUrl ==[c] %@", ad.imageUrl)
        
        do {
            let result = try backgroundContext.fetch(fetchRequest)
            if let ads = result as? [Ads] {
                if ads.isEmpty { return false }
                
                for ad in ads {
                    ad.setValue(newAd.imageUrl, forKey: "imageUrl")
                    ad.setValue(newAd.price, forKey: "price")
                    ad.setValue(newAd.location, forKey: "location")
                    ad.setValue(newAd.title, forKey: "title")
                    ad.setValue(newAd.isFavorited, forKey: "isFavorited")
                    try backgroundContext.save()
                }
            }
        } catch {
            debugPrint("[ERROR]: Failed to update record, error:\(error)")
        }
        
        return true
    }
    
    /** Check if ad exists in Core Data
     */
    func exists(ad: AdItem) -> AdItem? {
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        fetchRequest.predicate = NSPredicate(format: "imageUrl ==[c] %@", ad.imageUrl)

        do {
            let result = try backgroundContext.fetch(fetchRequest)
            if let ads = result as? [Ads] {
                if ads.isEmpty { return nil } else { return ads.first?.convertToAdItem() }
            }
        } catch {
            debugPrint("[ERROR]: Failed to fetch data from CoreData, error:\(error)")
        }
        
        return nil
    }
}
