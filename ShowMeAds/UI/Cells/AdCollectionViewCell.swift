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
        label.backgroundColor = .darkGray
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.layer.opacity = 0.80
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
        label.font = UIFont.scaledFINNFont(fontType: .medium, size: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    fileprivate lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.font = UIFont.scaledFINNFont(fontType: .medium, size: 14)
        label.textColor = .gray
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.font = UIFont.scaledFINNFont(fontType: .regular, size: 18)
        label.textColor = .black
        label.textAlignment = .left
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
    
    fileprivate lazy var contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    fileprivate lazy var titleContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    // MARK: - Property injection
    
    public var model: AdItem? {
        didSet {
            guard let model = model else { return }
            
            model.loadImage(imageUrl: model.imageUrl) { (imageData) in
                DispatchQueue.main.async {
                    self.imageView.image = UIImage.init(data: imageData)
                }
            }
            
            priceLabel.text = (model.price == 0) ?  "Gis bort" : "\(model.price),-"
            locationLabel.text = model.location
            titleLabel.text =  model.title
            heartButton.isSelected  = (model.isFavorited == true) ? true : false
        }
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentContainerView.addSubview(imageView)
        contentContainerView.addSubview(priceLabel)
        contentContainerView.addSubview(heartButton)
        
        titleContainerView.addArrangedSubview(locationLabel)
        titleContainerView.addArrangedSubview(titleLabel)
        
        addSubview(contentContainerView)
        addSubview(titleContainerView)
        
        NSLayoutConstraint.activate([
            contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: topAnchor),
            contentContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75),
            
            priceLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentContainerView.centerXAnchor),
            priceLabel.heightAnchor.constraint(equalTo: contentContainerView.heightAnchor, multiplier: 0.2),
            priceLabel.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            
            heartButton.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -.mediumSpacing),
            heartButton.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: .mediumSpacing),
            
            titleContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleContainerView.topAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: .smallSpacing),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Selector methods

extension AdCollectionViewCell {
    @objc func didTapHeartButton(sender: UIButton) {
        guard let ad = model else { return }
        
        UIView.animate(withDuration: 0.1, animations: { [unowned self] in
            sender.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            
            switch self.heartButton.isSelected {
            case true:
                self.heartButton.isSelected = false
                self.delegate?.didUnfavorite(ad: ad)
            case false:
                self.heartButton.isSelected = true
                self.delegate?.didFavorite(ad: ad)
            }
        }) { (didAnimate) in
            sender.transform = CGAffineTransform.identity
        }
    }
}
