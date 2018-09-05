//
//  AdStateViewController.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 23/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

protocol StateContainable {
    func setup()
}

public enum State {
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

    init(_ networkService: AdNetworkService, _ persistenceService: AdPersistenceService, _ imageCache: AdImageCacheService) {
        self.networkService = networkService
        self.persistenceService = persistenceService
        self.imageCache = imageCache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        transition(to: .loading)
        let items = persistenceService.fetch(where: nil)
        if items.count > 0 {
            let viewController = AdCollectionViewController(items, persistenceService, imageCache)
            transition(to: .loaded(viewController))
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
    private enum EndpointType {
        case remote
        case database
    }
    
    private func fetchAds(endpoint: EndpointType) {
        switch endpoint {
        case .remote:
            networkService.fetch(completionHandler: { [weak self] (response) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .error(_):
                    DispatchQueue.main.async {
                        strongSelf.transition(to: .error)
                    }
                case .success(let ads):
                    let filteredAds = strongSelf.persistenceService.updateOrInsert(ads)
                    DispatchQueue.main.async {
                        let viewController = AdCollectionViewController(filteredAds, strongSelf.persistenceService, strongSelf.imageCache)
                        strongSelf.transition(to: .loaded(viewController))
                    }
                }
            })
            
        case .database:
            let ads = persistenceService.fetch(where: nil)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                let viewController = AdCollectionViewController(ads, strongSelf.persistenceService, strongSelf.imageCache)
                strongSelf.transition(to: .loaded(viewController))
            }
        }
    }
}
