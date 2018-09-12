//
//  AdStateViewController.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 23/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdStateContainerController: UIViewController {
    
    // MARK: Private properties
    
    fileprivate var state: State? = nil
    fileprivate var shownNavigationController: UINavigationController?
    
    // MARK: Dependencies
    
    fileprivate var adService: AdService
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adService.dataSource = self
        
        switch adService.hasSavedAds() {
        case true:
            adService.fetchAds(endpoint: .database)
        case false:
            transition(to: .loading)
            adService.fetchAds(endpoint: .remote)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ adService: AdService) {
        self.adService = adService
        super.init(nibName: nil, bundle: nil)
    }
}

// MARK: Public methods for transitioning between states from child viewcontrollers

extension AdStateContainerController {
    public func transition(to newState: State) {
        guard state != newState else { return }
        
        shownNavigationController?.remove()
        
        let navigationController = navigationControllerFor(state: newState)
        add(child: navigationController)
        
        state = newState
        shownNavigationController = navigationController
    }
}

// MARK: Private Methods for modifying state of the container viewcontroller

extension AdStateContainerController {
    private func navigationControllerFor(state: State) -> UINavigationController {
        switch state {
        case .loading:
            let loadingViewController = AdLoadingViewController()
            let navigationController = UINavigationController.init(rootViewController: loadingViewController)
            navigationController.viewControllers = [loadingViewController]
            return navigationController
        case .loaded(let loadedViewController):
            let navigationController = UINavigationController.init(rootViewController: loadedViewController)
            navigationController.viewControllers = [loadedViewController]
            return navigationController
        case .error:
            let errorViewController = AdErrorViewController(adService: adService)
            let navigationController = UINavigationController.init(rootViewController: errorViewController)
            navigationController.viewControllers = [errorViewController]
            return navigationController
        }
    }
}

// MARK: AdDataSource conformance

extension AdStateContainerController: AdServiceDataSource {
    func didUpdate(ads: [AdItem]) {
        // On startup and between state transitions the navigation controller has no topViewController
        // We have to check that it exists before calling protocol conformance methods
        if let presentedViewController = shownNavigationController?.topViewController as? StateContainableDataSource {
            presentedViewController.willUpdateState(ads: ads)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let viewController = AdCollectionViewController(ads, strongSelf.adService)
            strongSelf.transition(to: .loaded(viewController))
            
        }
    }
}
