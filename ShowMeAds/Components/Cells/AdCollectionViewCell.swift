//
//  AdCollectionViewCell.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdCollectionViewCell: UICollectionViewCell {
    public static let nib = "AdCollectionViewCell"
    public static let identifier = "AdCollectionViewCellIdentifier"

    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.adImageView.layer.cornerRadius = 3
        self.adImageView.layer.masksToBounds = true
        self.priceLabel.layer.cornerRadius = 3
        self.priceLabel.layer.masksToBounds = true
    }

    func setup(imageUrl: String, price: Int32, location: String, title: String) {
        
        if price == 0 { self.priceLabel.text = "Gis bort" } else { self.priceLabel.text = "\(price),-" }
        self.locationLabel.text = location
        self.titleLabel.text = title
    }

    fileprivate func fetchImage(imageUrl: String) {
        if Reachability.isConnectedToNetwork() {
            getRemote(imageUrl: imageUrl)
        } else {
            getLocal(imageUrl: imageUrl)
        }
    }

    fileprivate func getRemote(imageUrl: String) { }
    fileprivate func getLocal(imageUrl: String) { }
}
