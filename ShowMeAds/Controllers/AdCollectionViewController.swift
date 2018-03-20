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
    fileprivate var isOffline: Bool = false
    fileprivate let sectionCount = 1
    
    fileprivate let emptyViewController = EmptyViewController()
    
    fileprivate let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftTitleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: offlineSwitch)
        
        self.collectionView?.register(UINib.init(nibName: AdCollectionViewCell.nib, bundle: nil),
                                      forCellWithReuseIdentifier: AdCollectionViewCell.identifier)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.backgroundColor = .white
        self.collectionView?.refreshControl = self.refreshControl
        
        self.offlineSwitch.addTarget(self, action: #selector(didTapOfflineMode), for: .touchUpInside)
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
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Selectors
    
    @objc func didTapOfflineMode() {
        if self.offlineSwitch.isOn == true {
            self.isOffline = true
            self.ads = []
            self.fetchFavoriteAds()
        } else {
            self.isOffline = false
            self.ads = []
            fetchAds(onCompletion: {})
        }
    }
    
    @objc func pullToRefresh() {
        fetchAds(onCompletion: { self.refreshControl.endRefreshing() })
    }
    
    // MARK: - Private
    
    fileprivate func fetchAds(onCompletion: @escaping (() -> Void)) {
        let spinnerView = UIViewController.displaySpinner(onView: self.collectionView!)
        
        AdsFacade.shared.fetchAds { (ads, isOffline) in
            self.ads = ads
            
            DispatchQueue.main.async {
                spinnerView.removeFromSuperview()
                self.collectionView?.reloadData()
                onCompletion()
            }
        }
    }

    fileprivate func fetchFavoriteAds() {
        AdsFacade.shared.fetchFavoriteAds { (ads) in
            self.ads = ads
            DispatchQueue.main.async {
                if self.ads.count == 0 {
                    self.showEmptyViewController()
                    self.goOnline()
                }
                self.collectionView?.reloadData()
            }
        }
    }
    
    fileprivate func showEmptyViewController() {
        self.navigationController?.pushViewController(self.emptyViewController, animated: true)
    }
    
    fileprivate func goOnline() {
        self.isOffline = false
        self.offlineSwitch.isOn = false
    }
}

// MARK: - UICollectionViewControllerDataSource

extension AdCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sectionCount
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return self.ads.count == 0 ? 10 : self.ads.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCollectionViewCell.identifier,
                                           for: indexPath)

        if  let adCell = cell as? AdCollectionViewCell {
            //  Get notified when cell is liked
            adCell.delegate = self
            
            if self.ads.count > 0 {
                let ad = self.ads[indexPath.row]
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
        let indexPath = self.collectionView!.indexPath(for: cell)!
        
        guard self.ads.count > 1 else {
            self.ads.remove(at: indexPath.row)
            self.showEmptyViewController()
            self.goOnline()
            self.collectionView?.reloadData()
            return
        }
        
        self.collectionView?.performBatchUpdates({
            self.ads.remove(at: indexPath.row)
            self.collectionView?.deleteItems(at: [indexPath])
        }, completion: { (_) in })
    }
}
