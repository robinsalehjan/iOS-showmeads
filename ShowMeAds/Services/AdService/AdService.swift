//
//  AdService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import CoreData

final class AdService {
    fileprivate var adRequestService: AdRequestService
    fileprivate var adProcessorService: AdProcessorService

    init(endpoint: String) {
        self.adProcessorService = AdProcessorService.init()
        self.adRequestService = AdRequestService.init(endpoint: endpoint, adProcessorService: self.adProcessorService)
    }

    func get(completion: @escaping ([NSManagedObjectID]) -> Void) {
        // 1. Check if we are online
        if Reachability.isConnectedToNetwork() {
            // 2. If yes, ask adRequestService to fetch remote
            self.adRequestService.getRequest(completion: completion)
        } else {
            // 3. If no, ask adProcessorService to fetch local
        }
    }
}
