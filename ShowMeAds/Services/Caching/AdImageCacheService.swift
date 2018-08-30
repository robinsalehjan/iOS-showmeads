//
//  AdCachingService.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 13/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

class CacheService<KeyType, ObjectType> : NSObject where KeyType: NSObjectProtocol, ObjectType: NSObjectProtocol {
    fileprivate let memoryCache = NSCache<KeyType, ObjectType>()
}

/** Image caching service
 responsible for caching images from both remote endpoints and disk.
 */
class AdImageCacheService: CacheService<NSString, NSData> {
    fileprivate let diskCache = AdDiskCacheService()
    
    // MARK - Public methods
    
    func fetch(url: String, onCompletion: @escaping (_ data: NSData) -> Void) {
        guard let validUrl = URL.isValid(url) else {
            debugPrint("[ERROR]: The URL string: \(url) is not valid")
            return
        }
        
        let key = url as NSString
        
        guard let valueInCache = memoryCache.object(forKey: url as NSString) else {
            guard let valueOnDisk = diskCache.fetchFromDisk(key: url) else {
                fetch(url: validUrl, onCompletion: onCompletion)
                return
            }
            
            memoryCache.setObject(valueOnDisk, forKey: key)
            onCompletion(valueOnDisk)
            return
        }
        
        onCompletion(valueInCache)
        return
    }
    
    @discardableResult
    func remove(url: String) -> Bool {
        let key = url as NSString
        
        guard let _ = memoryCache.object(forKey: key) else { return false }
        memoryCache.removeObject(forKey: key)
        diskCache.deleteFromDisk(key: url)
        
        return true
    }
    
    @discardableResult
    func removeAll() -> Bool {
        memoryCache.removeAllObjects()
        diskCache.clearDisk()
        
        return true
    }
    
    // MARK: Private methods
    
    private func fetch(url: URL, onCompletion: @escaping (_ data: NSData) -> Void) {
        guard Reachability.isConnectedToNetwork() else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
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
                    
                    self?.memoryCache.setObject(responseDataToNSData, forKey: key)
                    
                    onCompletion(responseDataToNSData)
                default:
                    debugPrint("[INFO]: Not supported status code: \(response.statusCode)" +
                        " headers: \(response.allHeaderFields)")
                }
            }
        }.resume()
    }
}
