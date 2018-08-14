//
//  DiskCacheService.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 13/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import UIKit

/** Disk cache for persisted resources
 */
class AdDiskCacheService {
    fileprivate let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func isCachedToDisk(url: String) -> URL? {
        let documentPath = documentDirectory.path
        let filePath = documentDirectory.appendingPathComponent("\(url)")
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentPath)
            for file in files {
                let existingFilePath = "\(documentPath)/\(file)"
                if existingFilePath == filePath.path {
                    print("Item already exists in directory")
                    return filePath
                }
            }
        } catch {
            print("[ERROR]: Could not add item to directory: \(error)")
        }
        return nil
    }
    
    func fetchFromDiskCache(url: String) {
        guard let filePath = isCachedToDisk(url: url) else { return }
        let data = NSData.init(contentsOf: filePath)
    }
    
    func saveToDiskCache(url: String, data: NSData) {
        guard isCachedToDisk(url: url) != nil else {
            let filePath = documentDirectory.appendingPathComponent("\(url)")
            if data.write(to: filePath, atomically: true) {
                print("Successfully wrote bytes to file path: \(filePath)")
            }
            return
        }
    }
    
    func deleteFromDiskCache(url: String) {
        let documentPath = documentDirectory.path
        let deletableFile = documentDirectory.appendingPathComponent("\(url)")
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentPath)
            for file in files {
                let existingFile = "\(documentPath)/\(file)"
                if existingFile == deletableFile.path {
                    try FileManager.default.removeItem(atPath: existingFile)
                }
            }
        } catch {
            print("[ERROR]: Failed to get the directory")
        }
    }
}
