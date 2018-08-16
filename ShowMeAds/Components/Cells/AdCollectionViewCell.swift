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
        adImageView.backgroundColor = UIColor(red: 0.00, green: 0.67, blue: 0.94, alpha: 1.0)
        adImageView.layer.cornerRadius = 10
        adImageView.layer.masksToBounds = true

        priceLabel.layer.cornerRadius = 10
        priceLabel.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        priceLabel.layer.masksToBounds = true

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
        if heartButton.isSelected {
            heartButton.isSelected = false
            delegate?.removeAdFromCollectionView(cell: self)
        } else {
            heartButton.isSelected = true
            ad.isFavorited = true
            delegate?.saveAdFromCollectionView(cell: self, adItem: ad)
        }
    }
    
    // MARK: - Public
    
    func setup(ad: AdItem) {
        self.ad = ad
        
        loadImage(imageUrl: ad.imageUrl)
        locationLabel.text = ad.location
        titleLabel.text = ad.title
        priceLabel.text = (ad.price == 0) ?  "Gis bort" : "\(ad.price),-"
        heartButton.isSelected  = (ad.isFavorited == true) ? true : false
    }
    
    // MARK: - Private

    fileprivate func loadImage(imageUrl: String) {
        guard let _ =  URL.init(string: imageUrl) else { fatalError("[ERROR]: The \(imageUrl) is of invalid format") }
        
        CacheFacade.shared.fetch(cacheType: .image, key: imageUrl) { [unowned self] (data: NSData) in
            let toData = data as Data
            let image = UIImage.init(data: toData)
            
            DispatchQueue.main.async {
                self.adImageView.image = image
            }
        }
    }
}
