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
    private var state: State?
    private var shownViewController: UIViewController?
    
    override func viewDidLoad() {
        if state == nil {
            transition(to: .loading)
        }
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

// MARK: Method to fetch ads from any given resource (database/server)

extension AdStateContainerController {
    private func fetchAds(endpoint: EndpointType) {
        AdsFacade.shared.fetchAds(endpoint: endpoint) { [weak self] (result) in
            switch result {
            case .error(_):
                DispatchQueue.main.async {
                    self?.transition(to: .error)
                }
            case .success(let ads):
                DispatchQueue.main.async {
                    let imageCacheService = AdImageCacheService()
                    let viewController = AdCollectionViewController(ads, imageCacheService: imageCacheService)
                    self?.transition(to: .loaded(viewController))
                }
            }
        }
    }
}
