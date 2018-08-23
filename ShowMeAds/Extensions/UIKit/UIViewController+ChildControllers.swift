//
//  UIViewController+ChildControllers.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 22/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Adds the argument passed in `childViewController` as a child of the parent view controller
    
    public func add(child: UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    /// Removes the given controller from the parent controller
    
    public func remove() {
        guard parent != nil else { return }
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}
