//
//  AdCachingService.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 13/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

class GenericCacheService<KeyType, ObjectType> : NSObject where KeyType: NSObjectProtocol, ObjectType: NSObjectProtocol {
    fileprivate let memoryCache = NSCache<KeyType, ObjectType>()
    
    func setObject(obj: ObjectType, forKey: KeyType) { }
    func getObject(forKey: KeyType) -> ObjectType? { return nil }
}

/** Client API to interact with the caching service
 */
class AdCacheService: GenericCacheService<NSString, NSData> {
    
    // MARK - Private properties
    
    fileprivate var diskCache = AdDiskCacheService()

    // MARK - Public properties

    static let shared = AdCacheService()
    override private init() { }
    
    // MARK - Public methods
    
    /** Caches an resource by either loading it from disk or fetching it remotely
     */
    func fetchFromCache(url: String, onCompletion: @escaping (_ data: NSData) -> Void) {
        guard let validUrl = URL.isValid(url) else {
            print("[ERROR]: The URL string: \(url) is not valid")
            return
        }
        
        // MARK: TODO - Need to load resources from disk into memory.
        
        guard let valueInCache = memoryCache.object(forKey: validUrl.absoluteString as NSString) else {
            guard Reachability.isConnectedToNetwork() else { return }
            URLSession.shared.dataTask(with: validUrl) { [unowned self] (data, response, error) in
                guard error == nil else {
                    print("[ERROR]: Failed to send request")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200:
                        guard let responseData = data else { return }
                        
                        let keyToNSString = validUrl.absoluteString as NSString
                        let responseDataToNSData = NSData.init(data: responseData)
                        
                        self.memoryCache.setObject(responseDataToNSData, forKey: keyToNSString)
                        
                        onCompletion(responseDataToNSData)
                    default:
                        print("[INFO]: Not supported status code: \(response.statusCode)" +
                            " headers: \(response.allHeaderFields)")
                    }
                }
            }.resume()
            
            return
        }
        
        onCompletion(valueInCache)
        return
    }
    
    func cacheToDiskCache(url: String, data: NSData) { }
    func evictFromDiskCache(url: String) { }
}
