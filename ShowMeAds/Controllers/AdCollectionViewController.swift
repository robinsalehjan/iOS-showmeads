//
//  ViewController.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdCollectionViewController: UICollectionViewController {
    // MARK: - Private properties
    fileprivate var ads: [AdItem] = []
    
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
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        collectionView?.register(UINib.init(nibName: AdCollectionViewCell.nib, bundle: nil),
                                 forCellWithReuseIdentifier: AdCollectionViewCell.identifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        
        collectionView?.refreshControl = refreshControl
        offlineSwitch.addTarget(self, action: #selector(didTapOfflineMode), for: .touchUpInside)
    }
    
    convenience init(_ ads: [AdItem]) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 2.5
        self.init(collectionViewLayout: layout)
        self.ads = ads
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: favoritesTitleLabel)
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: offlineSwitch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}

// MARK: - Private methods for state modifications

extension AdCollectionViewController {
    private func fetchAds(endpoint: EndpointType, onCompletion: (() -> Void)?) {
        AdsFacade.shared.fetchAds(endpoint: endpoint) { [weak self] (result) in
            switch result {
            case .error(let error):
                DispatchQueue.main.async {
                    self?.render(error)
                    if let completionHandler = onCompletion { completionHandler() }
                }
            case .success(let ads):
                DispatchQueue.main.async {
                    self?.render(ads)
                    if let completionHandler = onCompletion { completionHandler() }
                }
            }
        }
    }
    
    private func render(_ ads: [AdItem]) {
        self.ads = ads
        collectionView?.reloadData()
    }
    
    private func render(_ error: Error) {
        transition(to: .error)
    }
    
    private func transition(to newState: State) {
        guard let currentState = parent as? AdStateViewController else { return }
        switch newState {
        case .error:
            currentState.transition(to: .error)
        case .loading:
            currentState.transition(to: .loading)
        default:
            break
        }
    }
}

// MARK: - Private methods for UI modifications

extension AdCollectionViewController {
    private func showNoFavoritesLabel() {
        guard let collectionView = collectionView else { return }
        
        collectionView.addSubview(noFavoritesLabel)
        NSLayoutConstraint.activate([
            noFavoritesLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            noFavoritesLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -.veryLargeSpacing),
        ])
    }
}

// MARK: - Private selector methods

extension AdCollectionViewController {
    @objc func didTapOfflineMode() {
        switch offlineSwitch.isOn {
        case true:
            fetchAds(endpoint: .favorited, onCompletion: nil)
        case false:
            transition(to: .loading)
        }
    }
    
    @objc func pullToRefresh() {
        switch offlineSwitch.isOn {
        case true:
            fetchAds(endpoint: .favorited, onCompletion: { [weak self] in
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            })
        case false:
            fetchAds(endpoint: .remote, onCompletion: { [weak self] in
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            })
        }
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

// MARK: - AdCollectionViewCellDelegate

extension AdCollectionViewController: AdCollectionViewCellDataSource {
    func didFavorite(ad: AdItem) {
        AdsFacade.shared.update(ad: ad)
    }
    
    func didUnfavorite(ad: AdItem) {
        AdsFacade.shared.update(ad: ad)
    }
}
