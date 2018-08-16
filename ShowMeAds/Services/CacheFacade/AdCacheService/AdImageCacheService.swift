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
}

/** Client API to interact with the image caching service for Ads
 */
class AdImageCacheService: GenericCacheService<NSString, NSData> {
    
    // MARK - Public methods
    
    /** Fetches an resource by either loading it from disk or fetching it remotely
     */
    func fetch(url: String, onCompletion: @escaping (_ data: NSData) -> Void) {
        guard let validUrl = URL.isValid(url) else {
            debugPrint("[ERROR]: The URL string: \(url) is not valid")
            return
        }
        
        guard let valueInCache = memoryCache.object(forKey: url as NSString) else {
            guard let valueOnDisk = AdDiskCacheService.shared.fetchFromDisk(key: url) else {
                // Value does not exist in cache or on disk.
                fetchFromRemote(url: validUrl, onCompletion: onCompletion)
                return
            }
            
            let key = url as NSString
            memoryCache.setObject(valueOnDisk, forKey: key)
            onCompletion(valueOnDisk)
            
            debugPrint("[INFO]: Loaded \(url) from disk cache")
            return
        }
        
        // Value exists in cache
        onCompletion(valueInCache)
        return
    }
    
    func evict(url: String) {
        let key = url as NSString
        guard let _ = memoryCache.object(forKey: key) else { return }
        memoryCache.removeObject(forKey: key)
        debugPrint("[INFO]: Evicted \(url) from cache")
    }
    
    // MARK: Private methods
    
    private func fetchFromRemote(url: URL, onCompletion: @escaping (_ data: NSData) -> Void) {
        guard Reachability.isConnectedToNetwork() else { return }
        
        
        URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
            guard error == nil else {
                debugPrint("[ERROR]: Failed to send request")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    guard let responseData = data else { return }
                    
                    let key = url.absoluteString as NSString
                    let responseDataToNSData = NSData.init(data: responseData)
                    
                    self.memoryCache.setObject(responseDataToNSData, forKey: key)
                    
                    onCompletion(responseDataToNSData)
                default:
                    debugPrint("[INFO]: Not supported status code: \(response.statusCode)" +
                        " headers: \(response.allHeaderFields)")
                }
            }
        }.resume()
    }
}
