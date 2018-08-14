//
//  AdCachingService.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 13/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

protocol GenericCacheServiceProtocol {
    associatedtype KeyType
    func objectForKey(key: KeyType, onCompletion: () -> Void)
}

class GenericCacheService<KeyType, ObjectType> : GenericCacheServiceProtocol where KeyType: AnyObject, ObjectType: AnyObject {
    fileprivate let memoryCache = NSCache<KeyType, ObjectType>()
    
    func objectForKey(key: KeyType, onCompletion: () -> Void) {}
}

/** Client API to interact with the caching service
 */
class AdCacheService: GenericCacheService<NSString, NSData> {
    
    // MARK - Properties
    
    fileprivate var diskCache = AdDiskCacheService()
    
    static let shared = AdCacheService()
    
    override private init() { }
    
    /** Creates and returns an UIImage from a given URL
     If the client has network access it fetches the UIImage from the remote resource, if not, it will fetch the latest cached UIImage.
     */
    func cache(url: String, onCompletion: () -> Void) {
        guard let validUrl = URL.isValid(url) else {
            print("[ERROR]: The URL string: \(url) is not valid")
            return
        }
        
        guard let _ = memoryCache.object(forKey: validUrl.absoluteString as NSString) else {
            // Does not exist in memory
            return
        }
    }
}
