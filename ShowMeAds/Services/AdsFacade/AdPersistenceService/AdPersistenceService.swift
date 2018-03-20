//
//  AdPersistenceService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 19/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import CoreData

class AdPersistenceService {

    // MARK: Properties

    fileprivate lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ShowMeAds")

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    // MARK: Public functions

    func fetchFavoriteAds(completionHandler: ((_ ads: [AdItem]) -> Void)) {
        var ads: [AdItem] = []

        let backgroundContext = self.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")

        do {
            let result = try backgroundContext.fetch(request)
            if let adObjects = result as? [Ads] {
                ads = adObjects.map { $0.convertToAdItem() }
                completionHandler(ads)
            }
        } catch {
            print("[ERROR]: Failed to fetch data from CoreData")
            completionHandler(ads)
        }
    }

    func save(ad: AdItem) {
        let backgroundContext = self.persistentContainer.newBackgroundContext()
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
            print("[ERROR]: Did not manage to save" +
                " objectID: \(newAd.objectID)" +
                " imageUrl: \(ad.imageUrl)" +
                " price: \(ad.price)" +
                " location: \(ad.location)" +
                " title: \(ad.title)")
        }
    }

    func remove(ad: AdItem) {
        let backgroundContext = self.persistentContainer.newBackgroundContext()
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
            print("[ERROR]: Failed to delete data from CoreData")
        }
    }

    func exists(ad: AdItem) -> AdItem? {
        let backgroundContext = self.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")
        fetchRequest.predicate = NSPredicate(format: "imageUrl ==[c] %@", ad.imageUrl)
        fetchRequest.fetchLimit = 1

        do {
            let result = try backgroundContext.fetch(fetchRequest)
            if let ads = result as? [Ads] {
                if ads.isEmpty { return nil } else { return ads.first?.convertToAdItem() }
            }
        } catch {
            print("[ERROR]: Failed to fetch data from CoreData")
        }

        return nil
    }
}
