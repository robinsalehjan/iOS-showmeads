//
//  EmptyViewController.swift
//  ShowMeAds
//
//  Created by Robin Saleh-Jan on 20/3/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc fileprivate func dismiss(sender: UILongPressGestureRecognizer) {
        self.navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
