//
//  ViewController.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 16/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdCollectionViewController: UICollectionViewController {
    fileprivate let leftTitleLabel: UILabel = {
        let label = UILabel()
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
        let attributeString = NSMutableAttributedString(string: "Kun favoritter", attributes: attributes)
        label.attributedText = attributeString
        return label
    }()

    fileprivate let offlineSwitch: UISwitch = {
        let offlineSwitch = UISwitch()
        return offlineSwitch
    }()

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
        print("Go to offline mode")
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
        return 6
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let adCell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCollectionViewCell.identifier,
                                                        for: indexPath)
        return adCell
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
