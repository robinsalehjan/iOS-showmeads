//
//  Ad+CoreDataClass.swift
//  
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//
//

import Foundation
import CoreData

public struct AdItem {
    var imageUrl: String
    var price: Int32
    var location: String
    var title: String
    var isFavorited: Bool
    
    var description: String {
        return "imageUrl: \(imageUrl)" +
                " price: \(price)" +
                " location: \(location)" +
                " title: \(title)" +
                " isFavorited: \(isFavorited)"
    }
    
    // MARK: - Dependency injection
    
    var imageCache: AdImageCacheService
    var diskCache: AdDiskCacheService
    
    init(_ imageUrl: String = "", _ price: Int32 = 0, _ location: String = "",
         _ title: String = "", _ isFavorited: Bool = false,
         _ imageCache: AdImageCacheService = AdImageCacheService(), _ diskCache: AdDiskCacheService = AdDiskCacheService()) {
        self.imageUrl = imageUrl
        self.price = price
        self.location = location
        self.title = title
        self.isFavorited = isFavorited
        self.imageCache = imageCache
        self.diskCache = diskCache
    }
    
    // MARK: - Public methods
    
    func diff(ad: AdItem) -> Bool {
        if self.title != ad.title { return true }
        return false
    }
    
    func loadImage(imageUrl: String, onCompletion: @escaping (_ Data: Data) -> Void) {
        guard URL.init(string: imageUrl) != nil else { fatalError("[ERROR]: The \(imageUrl) is of invalid format") }
        
        imageCache.fetch(url: imageUrl, onCompletion: { (data) in
            self.diskCache.saveToDisk(key: imageUrl, data: data)
            onCompletion(data as Data)
        })
    }
}

@objc(Ads)
public class Ads: NSManagedObject {
    public func convertToAdItem() -> AdItem {
        var adItem = AdItem()

        if let url = self.imageUrl {
            adItem.imageUrl = url
        }
        if let location = self.location {
            adItem.location = location
        }
        if let title = self.title {
            adItem.title = title
        }

        adItem.price = self.price
        adItem.isFavorited = self.isFavorited

        return adItem
    }
}
