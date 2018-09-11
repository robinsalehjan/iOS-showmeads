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
    
    fileprivate var state: State?
    fileprivate var shownViewController: UIViewController?
    
    // MARK: Dependencies
    
    fileprivate var adService: AdService
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if state == nil {
            transition(to: .loading)
        }
        
        adService.dataSource = self
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
        
        if let oldChild = shownViewController as? StateContainable { oldChild.willDismiss() }
        shownViewController?.remove()
        
        let viewController = viewControllerFor(state: newState)
        add(child: viewController)
        
        state = newState
        shownViewController = viewController
        if let newChild = shownViewController as? StateContainable { newChild.willPresent() }
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
            let errorViewController = AdErrorViewController(adService: adService)
            return errorViewController
        }
    }
}

// MARK: AdDataSource conformance

extension AdStateContainerController: AdServiceDataSource {
    func willUpdate() {
        transition(to: .loading)
    }
    
    func didUpdate(ads: [AdItem]) {
        if let child = shownViewController as? StateContainableDataSource { child.willUpdateState(ads: ads) }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let viewController = AdCollectionViewController(ads, strongSelf.adService)
            strongSelf.transition(to: .loaded(viewController))
        }
    }
}
