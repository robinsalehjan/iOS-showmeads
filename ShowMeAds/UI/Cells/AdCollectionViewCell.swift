//
//  AdCollectionViewCell.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

protocol AdCollectionViewCellDataSource: NSObjectProtocol {
    func didFavorite(ad: AdItem)
    func didUnfavorite(ad: AdItem)
}

class AdCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public properties
    
    public static let identifier = "AdCollectionViewCellIdentifier"
    
    public weak var delegate: AdCollectionViewCellDataSource?
    
    // MARK: - Private properties
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    fileprivate lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
        return label
    }()
    
    fileprivate lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    fileprivate lazy var heartButton: UIButton = {
        let button = UIButton()
        let unfilledHeartIcon = UIImage.init(named: "favorite-deselected")
        let filledHeartIcon = UIImage.init(named: "favorite-selected")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(unfilledHeartIcon, for: .normal)
        button.setImage(filledHeartIcon, for: .selected)
        button.addTarget(self, action: #selector(didTapHeartButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Property injection
    
    public var imageCache: AdImageCacheService?
    
    public var model: AdItem? {
        didSet {
            guard let model = model else { return }
            loadImage(imageUrl: model.imageUrl)
            priceLabel.text = (model.price == 0) ?  "Gis bort" : "\(model.price),-"
            locationLabel.text = model.location
            titleLabel.text =  model.title
            heartButton.isSelected  = (model.isFavorited == true) ? true : false
        }
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Selector methods

extension AdCollectionViewCell {
    @objc func didTapHeartButton(sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (didAnimate) in
            sender.transform = CGAffineTransform.identity
        }
        
        guard let ad = model else { return }
        
        switch heartButton.isSelected {
        case true:
            heartButton.isSelected = false
            delegate?.didUnfavorite(ad: ad)
        case false:
            heartButton.isSelected = true
            delegate?.didFavorite(ad: ad)
        }
    }
}

// MARK: - Private methods

extension AdCollectionViewCell {
    fileprivate func loadImage(imageUrl: String) {
        guard URL.init(string: imageUrl) != nil else { fatalError("[ERROR]: The \(imageUrl) is of invalid format") }
        
        imageCache?.fetch(url: imageUrl, onCompletion: { [unowned self] (data) in
            let toData = data as Data
            let image = UIImage.init(data: toData)
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        })
    }
}
