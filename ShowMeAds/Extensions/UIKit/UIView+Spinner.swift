//
//  UIViewController+Spinner.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 20/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

extension UIView {
    ///  Adds a loading spinner to the given `UIView`
 
    static func displaySpinner(parentView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: parentView.bounds)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            NSLayoutConstraint.activate([activityIndicator.heightAnchor.constraint(equalTo: spinnerView.heightAnchor),
                                         activityIndicator.widthAnchor.constraint(equalTo: spinnerView.widthAnchor),
                                         activityIndicator.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor),
                                         activityIndicator.centerYAnchor.constraint(equalTo: spinnerView.centerYAnchor)])
            
            parentView.addSubview(spinnerView)
            NSLayoutConstraint.activate([spinnerView.heightAnchor.constraint(equalTo: parentView.heightAnchor),
                                         spinnerView.widthAnchor.constraint(equalTo: parentView.widthAnchor),
                                         spinnerView.topAnchor.constraint(equalTo: parentView.topAnchor),
                                         spinnerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)])
        }

        return spinnerView
    }
    
    
    /// Removes a loading spinner from the given `UIView`

    static func removeSpinner(spinner: UIView?) {
        guard let spinner = spinner else { return }
        
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
