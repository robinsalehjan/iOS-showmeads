//
//  ErrorViewController.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 22/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class AdErrorViewController: UIViewController {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func didTapRefreshButton(sender: UIButton) {
        UIButton.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (didAnimate) in
            sender.transform = CGAffineTransform.identity
        }
        
        AdsFacade.shared.fetchAds(endpoint: .remote) { [weak self] (result) in
            switch result {
            case .success(let ads):
                guard let state = self?.parent as? AdStateViewController else { return }
                let vc = AdCollectionViewController.init(ads)
                DispatchQueue.main.async {
                    state.transition(to: .loaded(vc))
                }
            case .error(_):
                print("Still offline - No state has changed.")
            }
        }
    }
}
