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
    
    /** Fetch ads that has been favorited from Core Data
     */
    func fetchFavoriteAds(completionHandler: ((_ ads: [AdItem]) -> Void)) {
        var ads: [AdItem] = []
        
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        request.predicate = NSPredicate(format: "isFavorited == true")
        
        do {
            let result = try backgroundContext.fetch(request)
            if let adObjects = result as? [Ads] {
                ads = adObjects.map { $0.convertToAdItem() }
                completionHandler(ads)
            }
        } catch {
            debugPrint("[ERROR]: Failed to fetch data from CoreData")
            completionHandler(ads)
        }
    }
    
    /** Insert an ad into Core Data
     */
    func insert(ad: AdItem) {
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let entity = NSEntityDescription.entity(forEntityName: "Ads", in: backgroundContext)

        let newAd = Ads.init(entity: entity!, insertInto: backgroundContext)
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
    }
    
    /** Delete an ad from Core Data
     */
    func delete(ad: AdItem) {
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
    }
    
    /** Check if ad exists in Core Data
     */
    func exists(ad: AdItem) -> AdItem? {
        let backgroundContext = AppDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        fetchRequest.predicate = NSPredicate(format: "imageUrl ==[c] %@", ad.imageUrl)
        fetchRequest.fetchLimit = 1

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
