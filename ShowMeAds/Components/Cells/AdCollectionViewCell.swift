//
//  AdCollectionViewCell.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties

    public static let nib = "AdCollectionViewCell"
    public static let identifier = "AdCollectionViewCellIdentifier"

    public weak var delegate: AdCollectionViewCellDelegate?

    var ad: AdItem = AdItem()

    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adImageView.backgroundColor = UIColor(red: 0.00, green: 0.67, blue: 0.94, alpha: 1.0)
        self.adImageView.layer.cornerRadius = 10
        self.adImageView.layer.masksToBounds = true

        self.priceLabel.layer.cornerRadius = 10
        self.priceLabel.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        self.priceLabel.layer.masksToBounds = true

        let unfilledHeartIcon = UIImage.init(named: "empty-heart")
        let filledHeartIcon = UIImage.init(named: "filled-heart")
        self.heartButton.setImage(unfilledHeartIcon, for: .normal)
        self.heartButton.setImage(filledHeartIcon, for: .selected)
        self.heartButton.addTarget(self, action: #selector(didTapHeartButton), for: .touchUpInside)
    }

    override func prepareForReuse() {
        self.heartButton.isSelected = false
    }
    
    // MARK: - Selectors

    @objc func didTapHeartButton() {
        if self.heartButton.isSelected {
            self.heartButton.isSelected = false
            delegate?.removeAdFromCollectionView(cell: self)
        } else {
            self.heartButton.isSelected = true
            self.ad.isFavorited = true
            delegate?.saveAdFromCollectionView(cell: self, adItem: self.ad)
        }
    }
    
    // MARK: - Public
    
    func setup(ad: AdItem) {
        self.ad = ad
        
        // loadimage(imageUrl: self.ad.imageUrl)
        self.locationLabel.text = self.ad.location
        self.titleLabel.text = self.ad.title
        self.priceLabel.text = (self.ad.price == 0) ?  "Gis bort" : "\(self.ad.price),-"
        self.heartButton.isSelected  = (self.ad.isFavorited == true) ? true : false
    }
    
    // MARK: - Private

    fileprivate func loadimage(imageUrl: String) {
        guard let url =  URL.init(string: imageUrl) else {
            fatalError("[ERROR]: The URL is of invalid format")
        }
    }
}
