//
//  ViewController.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdCollectionViewController: UICollectionViewController {

    // MARK: Properties

    fileprivate var ads: [AdItem] = []
    fileprivate var isOffline: Bool = false

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

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        fetchAds()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftTitleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: offlineSwitch)

        self.collectionView?.register(UINib.init(nibName: AdCollectionViewCell.nib, bundle: nil),
                                      forCellWithReuseIdentifier: AdCollectionViewCell.identifier)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.backgroundColor = .white

        self.offlineSwitch.addTarget(self, action: #selector(didTapOfflineMode), for: .touchUpInside)
    }

    @objc func didTapOfflineMode() {
        if self.offlineSwitch.isOn == true {
            print("[INFO]: Set to offline")
            self.isOffline = true
            self.ads = []
            self.fetchFavoriteAds()
            print("[INFO]: offline ad count: \(self.ads.count)")
        } else {
            print("[INFO]: Set to online")
            self.isOffline = false
            self.ads = []
            self.fetchAds()
        }
    }

    fileprivate func fetchAds() {
        AdsFacade.shared.fetchAds { (ads, isOffline) in
            self.isOffline = isOffline
            self.ads = ads

            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }

    fileprivate func fetchFavoriteAds() {
        AdsFacade.shared.fetchFavoriteAds { (ads) in
            self.ads = ads
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - UICollectionViewControllerDataSource
extension AdCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
            guard self.ads.count > 0 else { return cell }
            let ad = self.ads[indexPath.row]
            adCell.setup(ad: ad)
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
