//
//  AdCollectionViewCellDelegate.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 20/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation

protocol AdCollectionViewCellDelegate: NSObjectProtocol {
    func removeAdFromCollectionView(row: Int)
}
