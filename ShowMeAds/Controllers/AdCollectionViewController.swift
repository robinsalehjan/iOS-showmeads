//
//  ViewController.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdCollectionViewController: UICollectionViewController, AdCollectionViewCellDelegate {
    
    // MARK: - Properties

    fileprivate var ads: [AdItem] = [] 
    fileprivate let sectionCount = 1
    
    fileprivate let emptyViewController = EmptyViewController()
    
    fileprivate let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Oppdaterer")
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    fileprivate let leftTitleLabel: UILabel = {
        let label = UILabel()
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
        let attributeString = NSMutableAttributedString(string: "Kun favoritter", attributes: attributes)
        label.attributedText = attributeString
        label.textColor = .white
        return label
    }()

    fileprivate let offlineSwitch: UISwitch = {
        let offlineSwitch = UISwitch()
        return offlineSwitch
    }()
    
    // MARK: - Initalizers
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftTitleLabel)
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
        fetchAds(onCompletion: {})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.offlineSwitch.isOn = false
        navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Selectors
    
    @objc func didTapOfflineMode() {
        guard offlineSwitch.isOn else {
            fetchAds(onCompletion: {})
            return
        }
        
        fetchFavoriteAds()
    }
    
    @objc func pullToRefresh() {
        fetchAds(onCompletion: {
            self.refreshControl.endRefreshing()
        })
    }
    
    // MARK: - Private
    
    fileprivate func fetchAds(onCompletion: @escaping (() -> Void)) {
        guard offlineSwitch.isOn else {
            if let collectionView = collectionView {
                let spinnerView = UIViewController.displaySpinner(onView: collectionView)
                
                AdsFacade.shared.fetchAds { (ads, isOffline) in
                    self.ads = ads
                    
                    DispatchQueue.main.async {
                        spinnerView.removeFromSuperview()
                        collectionView.reloadData()
                        onCompletion()
                    }
                }
            }
            return
        }
        
        onCompletion()
    }

    fileprivate func fetchFavoriteAds() {
        AdsFacade.shared.fetchFavoriteAds { (ads) in
            self.ads = ads
            
            DispatchQueue.main.async {
                guard self.ads.count == 0 else {
                    self.collectionView?.reloadData()
                    return
                }
                self.showEmptyViewController()
            }
        }
    }
    
    fileprivate func showEmptyViewController() {
        self.navigationController?.pushViewController(emptyViewController, animated: true)
    }
}

// MARK: - UICollectionViewControllerDataSource

extension AdCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return ads.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCollectionViewCell.identifier,
                                           for: indexPath)

        if  let adCell = cell as? AdCollectionViewCell {
            if ads.count > 0 {
                let ad = ads[indexPath.row]
                adCell.delegate = self
                adCell.setup(ad: ad)
            }
        }
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

        return UIEdgeInsets(top: topBottomInset, left: leftRightInset, bottom: topBottomInset, right: leftRightInset)
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

extension AdCollectionViewController {
    func removeAdFromCollectionView(cell: AdCollectionViewCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        if ads.count > 0 {
            let adItem = ads[indexPath.row]
            AdsFacade.shared.delete(ad: adItem)
        }
    }
    
    func saveAdFromCollectionView(cell: AdCollectionViewCell, adItem: AdItem) {
        guard collectionView?.indexPath(for: cell) != nil else { return }
        AdsFacade.shared.insert(ad: adItem)
    }
}
