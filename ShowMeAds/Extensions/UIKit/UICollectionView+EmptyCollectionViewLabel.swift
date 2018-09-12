//
//  UICollectionView+EmptyCollectionLabel.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 11/09/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

extension UICollectionView {
    public func showEmptyCollectionViewLabel(label: UILabel) {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -.veryLargeSpacing),
        ])
    }
}
