//
//  AdCollectionViewCellModel.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 31/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation


protocol AdCollectionViewCellModelProtocol {
    var title: String { get set }
    var location: String { get set }
    var price: Int { get set }
    var isFavorited: Bool { get set }
    var imageUrl: String { get set }
}

struct AdCollectionViewCellModel: AdCollectionViewCellModelProtocol {
    var title: String
    var location: String
    var price: Int
    var isFavorited: Bool
    var imageUrl: String
}
