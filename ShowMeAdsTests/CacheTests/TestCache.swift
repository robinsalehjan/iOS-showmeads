//
//  TestCache.swift
//  ShowMeAdsTests
//
//  Created by Saleh-Jan, Robin on 16/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import XCTest

@testable import ShowMeAds

class TestCache: XCTestCase {
    let key = "I dungoofed"
    let value = "Some bytes and stuff, dawg"
    
    func testIsSavedToDisk() {
        guard let data = value.data(using: .utf8) as NSData? else { fatalError() }
        CacheFacade.shared.saveToDisk(key: key, data: data as NSData)
        
        guard let savedData = CacheFacade.shared.fetchFromDisk(key: key)  as Data? else { fatalError() }
        assert(data.isEqual(to: savedData), "Did save \(data.debugDescription) to disk but fetched: \(savedData.debugDescription) from disk." +
            "Should return the same value for the given key.")
    }
    
    func testIsDeletedFromDisk() {
        guard let data = value.data(using: .utf8) as NSData? else { fatalError() }
        CacheFacade.shared.saveToDisk(key: key, data: data as NSData)
        
        CacheFacade.shared.deleteFromDisk(key: key)
        assert(CacheFacade.shared.fetchFromDisk(key: key) == nil, "The value associated with the key: \(key) was deleted." +
            "Should have returned nil from cache.")
    }
    
    override func tearDown() {
        super.tearDown()
        CacheFacade.shared.clearDisk()
    }
}
