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

    fileprivate var ads: [Ads] = []
    fileprivate var isOffline: Bool = false

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

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        fetchData()
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

    func fetchData() {
        self.ads = []

        AdService(endpoint: Endpoint.adUrl).get(completion: { [unowned self] (objectIds, isOffline) in
            if isOffline { print("[INFO]: The device is offline") } else { print("[INFO]: Successfully fetched data") }
            self.isOffline = isOffline
            
            for objectId in objectIds {
                DispatchQueue.main.async {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        let mainContext = appDelegate.persistentContainer.viewContext
                        if let ad = mainContext.object(with: objectId) as? Ads {
                            self.ads.append(ad)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        })
    }

    @objc func didTapOfflineMode() {
        print("Turn on offline mode")
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

            var imageUrl = ""
            var location = ""
            var title = ""

            if let adUrl = ad.imageUrl { imageUrl = adUrl }
            if let adLocation = ad.location { location = adLocation }
            if let adTitle = ad.title { title = adTitle }

            adCell.setup(imageUrl: imageUrl, price: ad.price, location: location, title: title)
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
