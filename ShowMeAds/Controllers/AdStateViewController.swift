//
//  AdStateViewController.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 23/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdStateViewController: UIViewController {
    fileprivate let stateViewController = StateViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AdStateViewController - viewDidLoad")
        
        view.backgroundColor = .white
        stateViewController.transition(to: .loading)
        
        fetchAds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AdStateViewController {
    private func fetchAds() {
        AdsFacade.shared.fetchAds { [unowned self] (result) in
            switch result {
            case .error(let error):
                DispatchQueue.main.async {
                    self.render(error)
                }
            case .success(let ads):
                DispatchQueue.main.async {
                    self.render(ads)
                }
            }
        }
    }
    
    private func render(_ ads: [AdItem]) {
        let vc = AdCollectionViewController(ads)
        stateViewController.transition(to: .loaded(vc))
    }
    
    private func render(_ error: Error) {
        stateViewController.transition(to: .failed)
    }
}

