//
//  State.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 11/09/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

public enum State {
    case loading
    case loaded(UIViewController)
    case error
}

extension State: Equatable {
    static public func ==(lhs: State, rhs: State) -> Bool {
        switch(lhs, rhs) {
        case (.loading, .loading): return true
        case (.loaded, .loaded): return true
        case (.error, .error): return true
        default: return false
        }
    }
    
    static public func !=(lhs: State, rhs: State) -> Bool {
        switch(lhs, rhs) {
        case (.loading, .loading): return false
        case (.loaded, .loaded): return false
        case (.error, .error): return false
        default: return true
        }
    }
}

public protocol StateContainableDataSource: NSObjectProtocol {
    func willUpdateState(ads: [AdItem])
}
