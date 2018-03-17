//
//  Ad+CoreDataClass.swift
//  
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//
//

import Foundation
import CoreData

struct AdStruct {
    var imageUrl: String = ""
    var price: Int = 0
    var location: String = ""
    var title: String = ""
}

@objc(Ads)
public class Ads: NSManagedObject {

}
