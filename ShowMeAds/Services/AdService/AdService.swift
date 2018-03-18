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

    func get(completion: @escaping (_ objectIds: [NSManagedObjectID], _ isOffline: Bool) -> Void) {
        self.adRequestService.getRequest(completion: completion)
    }
}
