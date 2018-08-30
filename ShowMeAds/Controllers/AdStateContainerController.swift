//
//  AdStateViewController.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 23/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

enum State {
    case loading
    case loaded(UIViewController)
    case error
}

class AdStateContainerController: UIViewController {
    
    // MARK: State properties
    
    private var state: State?
    private var shownViewController: UIViewController?
    
    // MARK: Dependencies
    
    fileprivate var networkService: AdNetworkService
    fileprivate var persistenceService: AdPersistenceService
    fileprivate var imageCache: AdImageCacheService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if state == nil {
            transition(to: .loading)
        }
    }
    
    init(_ networkService: AdNetworkService, _ persistenceService: AdPersistenceService, _ imageCache: AdImageCacheService) {
        self.networkService = networkService
        self.persistenceService = persistenceService
        self.imageCache = imageCache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let state = state else { return }
        guard case State.loading = state else { return }
    
        switch Reachability.isConnectedToNetwork() {
        case true:
            fetchAds(endpoint: .remote)
        case false:
            fetchAds(endpoint: .database)
        }
    }
}

// MARK: Methods for transitioning between states

extension AdStateContainerController {
    public func transition(to newState: State) {
        shownViewController?.remove()
        
        let viewController = viewControllerFor(state: newState)
        add(child: viewController)
        
        state = newState
        shownViewController = viewController
    }
}

// MARK: Methods for modifying the internal state of the parent view controller

extension AdStateContainerController {
    private func viewControllerFor(state: State) -> UIViewController {
        switch state {
        case .loading:
            return AdLoadingViewController()
        case .loaded(let viewController):
            return viewController
        case .error:
            return AdErrorViewController()
        }
    }
}

// MARK: Method to fetch ads from an given resource (remote/database)

extension AdStateContainerController {
    enum EndpointType {
        case remote
        case database
    }
    
    private func fetchAds(endpoint: EndpointType) {
        switch endpoint {
        case .remote:
            networkService.fetch(completionHandler: { [unowned self] (response) in
                switch response {
                case .error(_):
                    DispatchQueue.main.async {
                        self.transition(to: .error)
                    }
                case .success(let ads):
                    let filteredOutExistingAds: [AdItem] = ads.map {
                        if let existingAd = self.persistenceService.exists($0) {
                            self.persistenceService.update(existingAd)
                            return existingAd
                        } else {
                            self.persistenceService.insert($0)
                            return $0
                        }
                    }
                    DispatchQueue.main.async {
                        let viewController = AdCollectionViewController(filteredOutExistingAds, self.persistenceService, self.imageCache)
                        self.transition(to: .loaded(viewController))
                    }
                }
            })
            
        case .database:
            let ads = persistenceService.fetch(where: nil)
            DispatchQueue.main.async { [unowned self] in
                let viewController = AdCollectionViewController(ads, self.persistenceService, self.imageCache)
                self.transition(to: .loaded(viewController))
            }
        }
    }
}
