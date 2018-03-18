//
//  AdProcessorService.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 17/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation
import CoreData

final class AdRequestService {
    fileprivate var endpoint: String
    fileprivate var adProcessorService: AdProcessorService

    init(endpoint: String, adProcessorService: AdProcessorService) {
        self.endpoint = endpoint
        self.adProcessorService = adProcessorService
    }

    func getRequest(completion: @escaping ((_ objectIds: [NSManagedObjectID], _ isOffline: Bool) -> Void)) {
        if Reachability.isConnectedToNetwork() {
            getRemote(completion: completion)
        } else {
            getLocal(completion: completion)
        }
    }

    fileprivate func getRemote(completion: @escaping ((_ objectIds: [NSManagedObjectID], _ isOffline: Bool) -> Void)) {
        guard let endpointURL =  URL.init(string: self.endpoint) else {
            fatalError("[ERROR]: The URL is of invalid format")
        }

        let task = URLSession.shared.dataTask(with: endpointURL as URL!) { (data, response, error) in
            guard error == nil else {
                print("[ERROR]: Failed to make network request: \(error!) ")
                return
            }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    let objectIds = self.adProcessorService.storeData(data: data)
                    completion(objectIds, false)
                default:
                    print("[INFO]: Not supported status code: \(response.statusCode)" +
                        " headers: \(response.allHeaderFields)")
                }
            }
        }
        task.resume()
    }

    fileprivate func getLocal(completion: @escaping ((_ objectIds: [NSManagedObjectID], _ isOffline: Bool) -> Void)) {
        let objectIds = self.adProcessorService.fetchFromCoreData()
        completion(objectIds, true)
    }
}
