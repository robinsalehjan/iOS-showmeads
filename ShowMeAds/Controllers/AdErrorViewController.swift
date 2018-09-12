//
//  ErrorViewController.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 22/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdErrorViewController: UIViewController {
    
    // MARK: Private properties
    
    fileprivate var adService: AdService
    
    fileprivate lazy var errorLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.scaledFINNFont(fontType: .medium, size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .medium)
        let attributes = [NSAttributedStringKey.font: font]
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.attributedText = NSMutableAttributedString.init(string: "Ooops, her gikk det noe galt.", attributes: attributes)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    fileprivate lazy var refreshButton: UIButton = {
        let button = UIButton()
        let font = UIFont.scaledFINNFont(fontType: .medium, size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        let attributes = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.white]
        let attributedString = NSMutableAttributedString.init(string: "Prøv igjen", attributes: attributes)
        button.backgroundColor = .softBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(didTapRefreshButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(errorLabel)
        view.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -.mediumSpacing),
            refreshButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: .largeSpacing),
            refreshButton.centerXAnchor.constraint(equalTo: errorLabel.centerXAnchor),
            refreshButton.widthAnchor.constraint(equalTo: errorLabel.widthAnchor, multiplier: 0.25)
        ])
    }
    
    init(adService: AdService) {
        self.adService = adService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: Private selector methods

extension AdErrorViewController {
    @objc private func didTapRefreshButton(sender: UIButton) {
        UIButton.animate(withDuration: 0.1, animations: { [weak self] in
            sender.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            self?.adService.fetchAds(endpoint: .remote)
        }) { (_) in
            sender.transform = CGAffineTransform.identity
        }
    }
}
