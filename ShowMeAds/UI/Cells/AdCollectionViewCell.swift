//
//  AdCollectionViewCell.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

protocol AdCollectionViewCellDelegate: NSObjectProtocol {
    func removeAdFromCollectionView(cell: AdCollectionViewCell)
    func saveAdFromCollectionView(cell: AdCollectionViewCell, adItem: AdItem)
}

class AdCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public properties

    public static let nib = "AdCollectionViewCell"
    public static let identifier = "AdCollectionViewCellIdentifier"
    
    public weak var delegate: AdCollectionViewCellDelegate?
    
    // MARK: - Private properties
    
    private var ad: AdItem = AdItem()

    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        priceLabel.adjustsFontForContentSizeCategory = true
        locationLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontForContentSizeCategory = true
        
        adImageView.layer.cornerRadius = 10
        adImageView.layer.masksToBounds = true

        priceLabel.layer.cornerRadius = 10
        priceLabel.layer.masksToBounds = true
        priceLabel.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]

        let unfilledHeartIcon = UIImage.init(named: "favorite-deselected")
        let filledHeartIcon = UIImage.init(named: "favorite-selected")
        heartButton.setImage(unfilledHeartIcon, for: .normal)
        heartButton.setImage(filledHeartIcon, for: .selected)
        heartButton.addTarget(self, action: #selector(didTapHeartButton), for: .touchUpInside)
    }

    override func prepareForReuse() {
        self.heartButton.isSelected = false
    }
    
    // MARK: - Public methods
    
    func setup(ad: AdItem) {
        self.ad = ad
        
        loadImage(imageUrl: ad.imageUrl)
        locationLabel.text = ad.location
        titleLabel.text = ad.title
        priceLabel.text = (ad.price == 0) ?  "Gis bort" : "\(ad.price),-"
        heartButton.isSelected  = (ad.isFavorited == true) ? true : false
    }
}

// MARK: - Selector methods

extension AdCollectionViewCell {
    @objc func didTapHeartButton() {
        if heartButton.isSelected {
            heartButton.isSelected = false
            delegate?.removeAdFromCollectionView(cell: self)
        } else {
            heartButton.isSelected = true
            ad.isFavorited = true
            delegate?.saveAdFromCollectionView(cell: self, adItem: ad)
        }
    }
}

// MARK: - Private methods

extension AdCollectionViewCell {
    fileprivate func loadImage(imageUrl: String) {
        guard URL.init(string: imageUrl) != nil else { fatalError("[ERROR]: The \(imageUrl) is of invalid format") }
        
        CacheFacade.shared.fetch(cacheType: .image, key: imageUrl) { [unowned self] (data: NSData) in
            let toData = data as Data
            let image = UIImage.init(data: toData)
            
            DispatchQueue.main.async {
                self.adImageView.image = image
            }
        }
    }
}
