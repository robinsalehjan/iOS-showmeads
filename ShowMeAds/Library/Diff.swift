//
//  ArrayDiffing.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 12/09/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

// Improved from: https://stackoverflow.com/questions/36975864/swift-array-diff/37035519

import UIKit

typealias Insertions = [Int]
typealias Deletions = [Int]
typealias ChangeSet = (Insertions, Deletions)

func Diff<T: Equatable>(new: [T], old: [T]) -> ChangeSet {
    guard new.count > 0 && old.count > 0 else { return ChangeSet([], []) }
    
    let insertedObjects = new.filter({ !old.contains($0) })
    let insertionIndicies = insertedObjects.compactMap({ new.index(of: $0) })
    
    let deletedObjects = old.filter({ !new.contains($0) })
    let deletionIndicies = deletedObjects.compactMap({ old.index(of: $0) })
    
    return ChangeSet(insertionIndicies, deletionIndicies)
}
