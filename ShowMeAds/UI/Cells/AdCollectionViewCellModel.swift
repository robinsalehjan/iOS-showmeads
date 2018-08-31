//
//  AdCollectionViewCellModel.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 31/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import Foundation


protocol AdCollectionViewCellModelProtocol {
    var imageUrl: String { get set }
    var price: Int32 { get set }
    var location: String { get set }
    var title: String { get set }
    var isFavorited: Bool { get set }
}

struct AdCollectionViewCellModel: AdCollectionViewCellModelProtocol {
    var imageUrl: String
    var price: Int32
    var location: String
    var title: String
    var isFavorited: Bool
    
    func adItem() -> AdItem {
        return AdItem.init(self.imageUrl, self.price, self.location, self.title, self.isFavorited)
    }
}
