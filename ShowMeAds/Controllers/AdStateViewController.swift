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

class AdStateViewController: UIViewController {
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
        
        switch state {
        case .loading:
            AdsFacade.shared.fetchAds(endpoint: .remote) { [weak self] (result) in
                switch result {
                case .error(let error):
                    DispatchQueue.main.async {
                        self?.render(error)
                    }
                case .success(let ads):
                    DispatchQueue.main.async {
                        self?.render(ads)
                    }
                }
            }
        default:
            break
        }
    }
}

// MARK: Methods for transitioning between states

extension AdStateViewController {
    func transition(to newState: State) {

        shownViewController?.remove()
        
        let vc = viewController(for: newState)
        add(child: vc)
        
        state = newState
        shownViewController = vc
    }
    
    private func viewController(for state: State) -> UIViewController {
        switch state {
        case .loading:
            return AdLoadingViewController()
        case .loaded(let vc):
            return vc
        case .error:
            return AdErrorViewController()
        }
    }
}

// MARK: Methods for rendering child controllers

extension AdStateViewController {
    private func render(_ ads: [AdItem]) {
        let vc = AdCollectionViewController(ads)
        transition(to: .loaded(vc))
    }
    
    private func render(_ error: Error) {
        transition(to: .error)
    }
}

