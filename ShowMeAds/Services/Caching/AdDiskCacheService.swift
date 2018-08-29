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
final class AdDiskCacheService {
    // MARK: Private properties
    fileprivate let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
}

// MARK: Public methods

extension AdDiskCacheService {
    
    /// Retrieves the content saved in the file associated with the passed in `key`
    /// - returns: An `NSData` instance with the content of the associated file, otherwise nil.
    
    public func fetchFromDisk(key: String) -> NSData? {
        guard let filePath = isCachedToDisk(key: key) else { return nil }
        return NSData.init(contentsOf: filePath)
    }
    
    /// Creates an file on disk with name of the passed in `key` and contents of the passed in `data`
    /// - returns: true if it saves to disk, false otherwise.
    
    @discardableResult
    public func saveToDisk(key: String, data: NSData) -> Bool {
        guard let documentDirectory = documentDirectory else { return false }
        guard let encodedFileName = key.base64Encode() else { return false }
        let filePath = documentDirectory.appendingPathComponent("\(encodedFileName)")
        
        do {
            try data.write(to: filePath, options: .atomic)
            return true
        } catch {
            debugPrint("[ERROR]: Could not write data to specified path: \(filePath.absoluteString), error: \(error)")
        }
        
        return false
    }
    
    /// Deletes the file associated with the passed in `key`.
    /// - returns: True if it manages to delete the associated file, false otherwise.
    
    @discardableResult
    public func deleteFromDisk(key: String) -> Bool {
        guard let documentDirectory = documentDirectory else { return false }
        guard let encodedFileName = key.base64Encode() else { return false }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentDirectory.path)
            for file in files {
                guard let decodedFileName = file.base64Decode() else { return false}
                
                if key == decodedFileName {
                    let deletableFile = documentDirectory.appendingPathComponent("\(encodedFileName)")
                    try FileManager.default.removeItem(at: deletableFile)
                    return true
                }
            }
        } catch {
            debugPrint("[ERROR]: Failed to get contents of directory, error: \(error)")
        }
        
        return false
    }
    
    /// Deletes all files in the document directory
    /// - returns: True if it manages to delete the files, false otherwise.
    
    @discardableResult
    public func clearDisk() -> Bool {
        guard let documentDirectory = documentDirectory else { return false }
        
        do {
            let items = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: [])
            try items.forEach { item in try FileManager.default.removeItem(at: item) }
            return true
        } catch {
            debugPrint("[ERROR]: Failed to clear disk, error: \(error)")
        }
        
        return false
    }
}

// MARK: Private methods

extension AdDiskCacheService {
    
    /// Check if there's a file on disk matching the passed in `key`
    /// - returns: An `URL` instance with a reference to the file on disk.
    
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
