//
//  Result.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 22/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation

enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case error(Error)
}

enum Error: Swift.Error {
    case networkUnavailable
    case invalidStatusCode
    case invalidURL
}
