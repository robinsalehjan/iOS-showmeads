//
//  Ad+CoreDataProperties.swift
//  
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//
//

import Foundation
import CoreData

extension Ads {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ads> {
        return NSFetchRequest<Ads>(entityName: "Ads")
    }

    @NSManaged public var imageUrl: String?
    @NSManaged public var price: Int32
    @NSManaged public var location: String?
    @NSManaged public var title: String?
    @NSManaged public var isFavorited: Bool

}
