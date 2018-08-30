//
//  AdPersistenceService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 19/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import CoreData

/// Client API to interact with Core Data

class AdPersistenceService {
    
    /// Query for records matching the given predicate
    /// - returns: All records matching the given predicate
    
    func fetch(where predicate: NSPredicate?) -> [AdItem] {
        var matchingAds: [AdItem] = []
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        request.predicate = predicate
        
        do {
            let result = try backgroundContext.fetch(request)
            if let objects = result as? [Ads] {
                matchingAds = objects.map { $0.convertToAdItem() }
            }
        } catch {
            debugPrint("[ERROR]: Failed to fetch data from CoreData: \(error)")
        }
        
        return matchingAds
    }
    
    /// Insert an record into core data
    /// - returns: true if it was inserted, false otherwise.
    
    @discardableResult
    func insert(_ ad: AdItem) -> Bool {
        guard exists(ad) == nil else { return false }
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Ads", in: backgroundContext) else { return false }
        
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
    
    /// Delete an existing record from core data
    /// - returns: true if it was deleted, false otherwise.
    
    @discardableResult
    func delete(_ ad: AdItem) -> Bool {
        guard exists(ad) != nil else { return false }
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        fetchRequest.predicate = NSPredicate(format: "imageUrl ==[c] %@", ad.imageUrl)
        
        do {
            let results = try backgroundContext.fetch(fetchRequest)
            if let existingAds = results as? [Ads] {
                for existingAd in existingAds {
                    backgroundContext.delete(existingAd)
                }
            }
            try backgroundContext.save()
        } catch {
            debugPrint("[ERROR]: Failed to delete data from CoreData, error: \(error)")
        }
        
        return true
    }
    
    /// Update an existing record in core data
    /// - returns: true if it did update the record, false otherwise.
    
    @discardableResult
    func update(_ ad: AdItem) -> Bool {
        guard let existingAd = exists(ad) else { return false }
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        fetchRequest.predicate = NSPredicate(format: "imageUrl ==[c] %@", existingAd.imageUrl)
        
        do {
            let result = try backgroundContext.fetch(fetchRequest)
            if let existingAds = result as? [Ads] {
                if existingAds.isEmpty { return false }
                
                for existingAd in existingAds {
                    existingAd.setValue(ad.imageUrl, forKey: "imageUrl")
                    existingAd.setValue(ad.price, forKey: "price")
                    existingAd.setValue(ad.location, forKey: "location")
                    existingAd.setValue(ad.title, forKey: "title")
                    existingAd.setValue(ad.isFavorited, forKey: "isFavorited")
                    try backgroundContext.save()
                }
            }
        } catch {
            debugPrint("[ERROR]: Failed to update record, error:\(error)")
        }
        
        return true
    }
    
    /// Compares the `imageURL` property of the passed in `ad` to see if the `ad` already exists there.
    /// - returns: An `AdItem` instance if an match was found, otherwise nil.
 
    func exists(_ ad: AdItem) -> AdItem? {
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        fetchRequest.predicate = NSPredicate(format: "imageUrl ==[c] %@", ad.imageUrl)

        do {
            let result = try backgroundContext.fetch(fetchRequest)
            if let existingAds = result as? [Ads] {
                if existingAds.isEmpty { return nil } else { return existingAds.first?.convertToAdItem() }
            }
        } catch {
            debugPrint("[ERROR]: Failed to fetch data from CoreData, error:\(error)")
        }
        
        return nil
    }
    
    func updateOrInsert(_ ads: [AdItem]) -> [AdItem] {
        var entries: [AdItem] = []
        
        for ad in ads {
            guard let existingAd = exists(ad) else {
                insert(ad)
                entries.append(ad)
            }
            
            if existingAd.diff(ad: ad) {
                update(existingAd)
                entries.append(existingAd)
            }
        }
        return entries
    }
}
