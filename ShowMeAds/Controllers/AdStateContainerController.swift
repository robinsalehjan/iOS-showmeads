//
//  AdStateViewController.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 23/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

public enum State {
    case loading
    case loaded(UIViewController)
    case error
}

public protocol StateContainmentable {
    func setupState()
}

public protocol StateContainmentableDataSource: NSObjectProtocol {
    func didFetch(ads: [AdItem])
}

class AdStateContainerController: UIViewController, StateContainmentable {
    
    // MARK: Private properties
    
    fileprivate var state: State?
    fileprivate var shownViewController: UIViewController?
    
    fileprivate var networkService: AdNetworkService
    fileprivate var persistenceService: AdPersistenceService
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if state == nil {
            transition(to: .loading)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ networkService: AdNetworkService, _ persistenceService: AdPersistenceService) {
        self.networkService = networkService
        self.persistenceService = persistenceService
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let state = state else { return }
        
        switch state {
        case .loading:
            switch Reachability.isConnectedToNetwork() {
            case true:
                fetchAds(endpoint: .remote)
            case false:
                fetchAds(endpoint: .database)
            }
        case .error:
            break
        case .loaded(_):
            break
        }
    }
}

// MARK: Public methods for transitioning between states from child viewcontrollers

extension AdStateContainerController {
    public func transition(to newState: State) {
        shownViewController?.remove()
        
        let viewController = viewControllerFor(state: newState)
        add(child: viewController)
        
        state = newState
        shownViewController = viewController
        
        guard let child = shownViewController as? StateContainmentable else { return }
        child.setupState()
    }
}

// MARK: Private Methods for modifying state of the container viewcontroller

extension AdStateContainerController {
    private func viewControllerFor(state: State) -> UIViewController {
        switch state {
        case .loading:
            let loadingViewController = AdLoadingViewController()
            return loadingViewController
        case .loaded(let loadedViewController):
            return loadedViewController
        case .error:
            let errorViewController = AdErrorViewController()
            return errorViewController
        }
    }
}

// MARK: Private method to fetch ads from an given resource (remote/database)

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
                        let viewController = AdCollectionViewController(filteredAds, strongSelf.persistenceService)
                        strongSelf.transition(to: .loaded(viewController))
                    }
                }
            })
        case .database:
            let ads = persistenceService.fetch(where: nil)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                let viewController = AdCollectionViewController(ads, strongSelf.persistenceService)
                strongSelf.transition(to: .loaded(viewController))
            }
        }
    }
}

// MARK: StateContainmentable conformence

extension AdStateContainerController {
    func setupState() { }
}
