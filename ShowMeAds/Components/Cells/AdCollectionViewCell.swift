//
//  AdCollectionViewCell.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit
import SDWebImage

class AdCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties

    public static let nib = "AdCollectionViewCell"
    public static let identifier = "AdCollectionViewCellIdentifier"
    
    var ad: AdItem? = nil
    var row: Int = 0
    weak var delegate: AdCollectionViewCellDelegate?

    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

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
        self.ad = nil
        self.row = 0
        self.heartButton.isSelected = false
    }

    func setup(row: Int, ad: AdItem) {
        self.row = row
        self.ad = ad
        
        loadimage(imageUrl: (self.ad?.imageUrl)!)

        self.locationLabel.text = self.ad?.location
        self.titleLabel.text = self.ad?.title

        if self.ad?.price == 0 {
            self.priceLabel.text = "Gis bort"
        } else {
            self.priceLabel.text = "\(self.ad!.price),-"
        }

        if self.ad!.isFavorited { self.heartButton.isSelected = true }
    }

    @objc func didTapHeartButton() {
        if self.heartButton.isSelected {
            self.heartButton.isSelected = false
            if ad != nil {
                delegate?.removeAdFromCollectionView(row: self.row)
                AdsFacade.shared.remove(ad: self.ad!)
            }
        } else {
            self.heartButton.isSelected = true
            self.ad?.isFavorited = true
            if ad != nil { AdsFacade.shared.save(ad: self.ad!)}
        }
    }

    fileprivate func loadimage(imageUrl: String) {
        guard let url =  URL.init(string: imageUrl) else {
            fatalError("[ERROR]: The URL is of invalid format")
        }

        self.adImageView.sd_setShowActivityIndicatorView(true)
        self.adImageView.sd_setIndicatorStyle(.whiteLarge)

        self.adImageView.sd_setImage(with: url) { (_, error, _, _) in
            if error != nil {
                // Set fallback image
            }
        }
    }
}
