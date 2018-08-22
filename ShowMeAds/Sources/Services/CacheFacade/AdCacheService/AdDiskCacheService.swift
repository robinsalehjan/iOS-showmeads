//
//  DiskCacheService.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 13/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

/** Disk caching service
 responsible for fetching and saving resources to and from disk
 */
class AdDiskCacheService {
    // MARK: Private properties
    
    fileprivate let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    // MARK: Public properties
    
    static let shared = AdDiskCacheService()
    private init() {}
    
    // MARK: Public methods
    
    func fetchFromDisk(key: String) -> NSData? {
        guard let filePath = AdDiskCacheService.shared.isCachedToDisk(key: key) else { return nil }
        return NSData.init(contentsOf: filePath)
    }
    
    func saveToDisk(key: String, data: NSData) {
        guard let documentDirectory = documentDirectory else { return }
        guard let encodedFileName = key.base64Encode() else { return }
        let filePath = documentDirectory.appendingPathComponent("\(encodedFileName)")
        
        do {
            try data.write(to: filePath, options: .atomic)
            debugPrint("[INFO]: Did save \(key) to disk")
        } catch {
            debugPrint("[ERROR]: Could not write data to specified path: \(filePath.absoluteString), error: \(error)")
        }
    }
    
    func deleteFromDisk(key: String) {
        guard let documentDirectory = documentDirectory else { return }
        guard let encodedFileName = key.base64Encode() else { return }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentDirectory.path)
            for file in files {
                guard let decodedFileName = file.base64Decode() else { return }
                
                if key == decodedFileName {
                    let deletableFile = documentDirectory.appendingPathComponent("\(encodedFileName)")
                    try FileManager.default.removeItem(at: deletableFile)
                    debugPrint("[INFO]: Deleted \(key) from disk")
                }
            }
        } catch {
            debugPrint("[ERROR]: Failed to get contents of directory, error: \(error)")
        }
    }
    
    func clearDisk() {
        guard let documentDirectory = documentDirectory else { return }
        do {
            let items = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: [])
            try items.forEach { item in try FileManager.default.removeItem(at: item) }
        } catch {
            debugPrint("[ERROR]: Failed to clear disk, error: \(error)")
        }
    }
    
    // MARK: Private methods
    
    private func isCachedToDisk(key: String) -> URL? {
        guard let documentDirectory = documentDirectory else { return nil }
        guard let encodedFileName = key.base64Encode() else { return nil }
        
        do {
            let documentPath = documentDirectory.path
            let files = try FileManager.default.contentsOfDirectory(atPath: documentPath)
            
            if let cachedFileName = files.first(where: { $0 == encodedFileName }) {
                return documentDirectory.appendingPathComponent("\(cachedFileName)")
            }
            
        } catch {
            debugPrint("[ERROR]: Failed to get contents of directory, error: \(error)")
        }
        return nil
    }
}
