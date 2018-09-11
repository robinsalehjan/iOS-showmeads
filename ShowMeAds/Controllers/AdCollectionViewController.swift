//
//  ViewController.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit
import CoreData

class AdCollectionViewController: UICollectionViewController {
    
    // MARK: - Private properties
    
    fileprivate var ads: [AdItem] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.reloadData()
            }
        }
    }
    
    fileprivate var adService: AdService
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let font = UIFont.scaledFINNFont(fontType: .medium, size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        let attributes = [NSAttributedStringKey.font: font]
        refreshControl.attributedTitle = NSMutableAttributedString(string: "Oppdaterer", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    fileprivate lazy var favoritesTitleLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.scaledFINNFont(fontType: .bold, size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        let attributes = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.softBlue]
        let attributeString = NSMutableAttributedString(string: "Kun favoritter", attributes: attributes)
        label.attributedText = attributeString
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    fileprivate lazy var offlineSwitch: UISwitch = {
        let offlineSwitch = UISwitch()
        offlineSwitch.onTintColor = .softBlue
        return offlineSwitch
    }()
    
    fileprivate lazy var noFavoritesLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.scaledFINNFont(fontType: .medium, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        let attributes = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.softBlue]
        let attributedString = NSMutableAttributedString(string: "Du har ingen favoritter tilgjengelig", attributes: attributes)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = attributedString
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    // MARK: - Initalizers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(AdCollectionViewCell.self, forCellWithReuseIdentifier: AdCollectionViewCell.identifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        collectionView?.refreshControl = refreshControl
        
        offlineSwitch.addTarget(self, action: #selector(didTapOfflineMode), for: .touchUpInside)
    }
    
    init(_ ads: [AdItem], _ adService: AdService) {
        self.ads = ads
        self.adService = adService
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 2.5
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private selector methods

extension AdCollectionViewController {
    @objc func didTapOfflineMode() {
        switch offlineSwitch.isOn {
        case true:
            adService.fetchFavoritedAds()
        case false:
            adService.fetchAds()
        }
    }
    
    @objc func pullToRefresh() {
        refreshControl.endRefreshing()
        switch offlineSwitch.isOn {
        case true:
            adService.fetchFavoritedAds()
        case false:
            adService.fetchAds()
        }
    }
}

// MARK: - UICollectionViewDataSource conformance

extension AdCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch ads.count == 0 && offlineSwitch.isOn {
        case true:
            collectionView.showEmptyCollectionViewLabel(label: noFavoritesLabel)
        default:
            noFavoritesLabel.removeFromSuperview()
        }
        return ads.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCollectionViewCell.identifier,
                                                            for: indexPath) as? AdCollectionViewCell else { return UICollectionViewCell() }
        let ad = ads[indexPath.row]
        cell.delegate = self
        cell.model = ad
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout conformance

extension AdCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftRightInset = collectionView.frame.width * 0.015
        let topBottomInset = collectionView.frame.height * 0.02
        
        return UIEdgeInsets(top: topBottomInset, left: leftRightInset,
                            bottom: topBottomInset, right: leftRightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.frame.width * 0.475
        let cellHeight = collectionView.frame.height * 0.30
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - AdCollectionViewCellDelegate conformance

extension AdCollectionViewController: AdCollectionViewCellDataSource {
    func didFavorite(ad: AdItem) {
        adService.update(ad: ad, isFavorited: true)
    }
    
    func didUnfavorite(ad: AdItem) {
        adService.update(ad: ad, isFavorited: false)
    }
}

// MARK: StateContainmentable conformence

extension AdCollectionViewController {
    func setupState() {
        parent?.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: favoritesTitleLabel)
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: offlineSwitch)
    }
}

// MARK: StateContainmentableDataSource conformence

extension AdCollectionViewController {
    func didFetch(ads: [AdItem]) {
        print("Was called")
    }
}
