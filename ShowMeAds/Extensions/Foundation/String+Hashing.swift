//
//  String+Hashing.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 15/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation

extension String {
    /// Base64 encoding a string
    
    func base64Encode() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
        
    /// Base64 decoding a string
    
    func base64Decode() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
