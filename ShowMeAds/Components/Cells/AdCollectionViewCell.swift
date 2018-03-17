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
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.gray
        self.layer.cornerRadius = 5
    }
}
