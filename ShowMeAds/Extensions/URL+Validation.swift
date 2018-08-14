//
//  URL+Sanitizing.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 13/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation

extension URL {
    static func isValid(_ url: String) -> URL? {
        guard let endpoint = URL.init(string: url) else {
            print("[ERROR]: Could not construct a URL instance with the given url: \(url)")
            return nil
        }
        return endpoint
    }
}
