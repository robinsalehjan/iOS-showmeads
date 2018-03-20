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
    var imageUrl: String = ""
    var price: Int32 = 0
    var location: String = ""
    var title: String = ""
    var isFavorited: Bool = false

    var description: String {
        return "imageUrl: \(imageUrl)" +
                " price: \(price)" +
                " location: \(location)" +
                " title: \(title)" +
                " isFavorited: \(isFavorited)"
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
