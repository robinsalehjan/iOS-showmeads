//
//  AdProcessorService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

final class AdProcessorService {

    // MARK: Properties

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ShowMeAds")

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: Public functions

    func storeData(data: Data?) -> [NSManagedObjectID] {
        let dictionary = serializeToDictionary(data: data)
        let parsedAds: [AdStruct] = parse(dictionary: dictionary)

        // In case of failure during serialization or parsing
        // Fetch locally stored data
        guard parsedAds.isEmpty == false else {
            print("[ERROR]: Could not fetch ads, using local data")
            let objectIds = fetchFromCoreData()
            return objectIds
        }

        let objectIds = saveToCoreData(ads: parsedAds)
        return objectIds
    }

    func fetchFromCoreData() -> [NSManagedObjectID] {
        var objectIds: [NSManagedObjectID] = []

        let backgroundContext = self.persistentContainer.newBackgroundContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Ads")

        do {
            let result = try backgroundContext.fetch(request)
            if let ads = result as? [Ads] {
                for ad in ads {
                    objectIds.append(ad.objectID)
                }
            }
        } catch {
            print("[ERROR]: Failed to fetch data from CoreData")
        }

        return objectIds
    }

    // MARK: - Private functions

    private func serializeToDictionary(data: Data?) -> [String: Any] {
        var dictionary: [String: Any] = [:]

        if let responseData = data {
            let json = try? JSONSerialization.jsonObject(with: responseData, options: [])
            if let dictionaryData = json as? [String: Any] {
                dictionary = dictionaryData
            }
        }
        return dictionary
    }

    private func parse(dictionary: [String: Any]) -> [AdStruct] {
        var ads: [AdStruct] = []

        if let items = dictionary["items"] as? [Any] {
            for item in items {
                var ad = AdStruct()

                if let itemDictionary = item as? [String: Any] {
                    if let imageDictionary = itemDictionary["image"] as? [String: Any] {
                        if let imageUrl = imageDictionary["url"] as? String {
                            ad.imageUrl = "\(Endpoint.imageBaseUrl)\(imageUrl)"
                        }
                    }
                    if let priceDictionary = itemDictionary["price"] as? [String: Any] {
                        if let price = priceDictionary["value"] as? Int32 {
                            ad.price = price
                        }
                    }
                    if let location = itemDictionary["location"] as? String {
                        ad.location = location
                    }
                    if let description = itemDictionary["description"] as? String {
                        ad.title = description
                    }
                }
                ads.append(ad)
            }
        }
        return ads
    }

    private func saveToCoreData(ads: [AdStruct]) -> [NSManagedObjectID] {
        var objectIds: [NSManagedObjectID] = []
        let backgroundContext = self.persistentContainer.newBackgroundContext()

        for ad in ads {
            let entity = NSEntityDescription.entity(forEntityName: "Ads", in: backgroundContext)
            let newAd = Ads.init(entity: entity!, insertInto: backgroundContext)

            newAd.setValue(ad.imageUrl, forKey: "imageUrl")
            newAd.setValue(ad.price, forKey: "price")
            newAd.setValue(ad.location, forKey: "location")
            newAd.setValue(ad.title, forKey: "title")

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

            objectIds.append(newAd.objectID)
        }

        return objectIds
    }
}
