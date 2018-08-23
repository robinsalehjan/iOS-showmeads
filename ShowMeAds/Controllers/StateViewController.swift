//
//  ContentStateViewController.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 22/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class StateViewController: UIViewController {
    private var state: State?
    private var shownViewController: UIViewController?
}

extension StateViewController {
    enum State {
        case loading
        case loaded(UIViewController)
        case failed
    }
}

extension StateViewController {
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
        case .failed:
            return AdErrorViewController()
        }
    }
}
