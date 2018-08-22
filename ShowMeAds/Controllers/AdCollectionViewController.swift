//
//  ViewController.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties

    fileprivate var ads: [AdItem] = []
    
    fileprivate let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let font = UIFont.scaledFINNFont(fontType: .medium, size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .medium)
        let attributes = [NSAttributedStringKey.font: font]
        refreshControl.attributedTitle = NSMutableAttributedString(string: "Oppdaterer", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    fileprivate let favoritesTitleLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.scaledFINNFont(fontType: .medium, size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        let attributes = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.softBlue]
        let attributeString = NSMutableAttributedString(string: "Kun favoritter", attributes: attributes)
        label.attributedText = attributeString
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    fileprivate let offlineSwitch: UISwitch = {
        let offlineSwitch = UISwitch()
        offlineSwitch.onTintColor = .softBlue
        return offlineSwitch
    }()
    
    let noFavoritesLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.scaledFINNFont(fontType: .medium, size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        let attributes = [NSAttributedStringKey.font: font]
        let attributedString = NSMutableAttributedString(string: "Du har ingen favoritter tilgjengelig", attributes: attributes)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = attributedString
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    // MARK: - Initalizers
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: favoritesTitleLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: offlineSwitch)
        
        collectionView?.register(UINib.init(nibName: AdCollectionViewCell.nib, bundle: nil),
                                 forCellWithReuseIdentifier: AdCollectionViewCell.identifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        
        collectionView?.refreshControl = refreshControl
        offlineSwitch.addTarget(self, action: #selector(didTapOfflineMode), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAds(onCompletion: {
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Private methods

extension AdCollectionViewController {
    private func fetchAds(onCompletion: @escaping (() -> Void)) {
        AdsFacade.shared.fetchAds { [unowned self] (ads, isOffline) in
            self.ads = ads
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                onCompletion()
            }
        }
    }
    
    private func fetchFavoriteAds() {
        AdsFacade.shared.fetchFavoriteAds { [unowned self] (ads) in
            self.ads = ads
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func showNoFavoritesLabel() {
        guard let collectionView = collectionView else { return }
        
        collectionView.addSubview(noFavoritesLabel)
        NSLayoutConstraint.activate([
            noFavoritesLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            noFavoritesLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -.veryLargeSpacing),
        ])
    }
}

// MARK: - Selector methods

extension AdCollectionViewController {
    @objc func didTapOfflineMode() {
        switch offlineSwitch.isOn {
        case true:
            fetchFavoriteAds()
        case false:
            fetchAds { [unowned self] in
                self.collectionView?.reloadData()
            }
        }
    }
    
    @objc func pullToRefresh() {
        fetchAds(onCompletion: { [unowned self] in
            self.refreshControl.endRefreshing()
        })
    }
}

// MARK: - UICollectionViewDataSource

extension AdCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch ads.count == 0 && offlineSwitch.isOn {
        case true:
            showNoFavoritesLabel()
        default:
            noFavoritesLabel.removeFromSuperview()
        }
        
        return ads.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCollectionViewCell.identifier,
                                                            for: indexPath) as? AdCollectionViewCell else { return UICollectionViewCell() }
        guard ads.count > 0 else { return cell }
        
        let ad = ads[indexPath.row]
        cell.delegate = self
        cell.setup(ad: ad)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AdCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        let leftRightInset = self.view.frame.width * 0.015
        let topBottomInset = self.view.frame.height * 0.02

        return UIEdgeInsets(top: topBottomInset, left: leftRightInset,
                            bottom: topBottomInset, right: leftRightInset)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidth = self.view.frame.width * 0.475
        let cellHeight = self.view.frame.height * 0.30

        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - AdCollectionViewCellDelegate

extension AdCollectionViewController: AdCollectionViewCellDelegate {
    func removeAdFromCollectionView(cell: AdCollectionViewCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        let adItem = ads[indexPath.row]
        AdsFacade.shared.delete(ad: adItem)
    }
    
    func saveAdFromCollectionView(cell: AdCollectionViewCell, adItem: AdItem) {
        guard collectionView?.indexPath(for: cell) != nil else { return }
        AdsFacade.shared.insert(ad: adItem)
    }
}
