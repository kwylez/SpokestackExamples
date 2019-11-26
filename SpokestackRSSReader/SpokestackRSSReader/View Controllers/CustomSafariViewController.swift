//
//  CustomSafariViewController.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/25/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import UIKit
import SafariServices

final class CustomSafariViewController: UIViewController {
    
    // MARK: Internal (properties)
    
    var url: URL? {
        
        didSet {
            
            /// when url changes, reset the safari child view controller
            
            self.configureChildViewController()
        }
    }

    // MARK: Private (properties)
    
    private var safariViewController: SFSafariViewController?

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureChildViewController()
    }

    // MARK: Private (methods)
    
    private func configureChildViewController() {
        
        /// Remove the previous safari child view controller if not nil
        
        if let safariViewController = safariViewController {
        
            safariViewController.willMove(toParent: self)
            safariViewController.view.removeFromSuperview()
            safariViewController.removeFromParent()
            self.safariViewController = nil
        }

        guard let url = url else {
            return
        }

        /// Create a new safari child view controller with the url
        
        let newSafariViewController = SFSafariViewController(url: url)
        addChild(newSafariViewController)
        
        newSafariViewController.view.frame = view.frame
        view.addSubview(newSafariViewController.view)
        
        newSafariViewController.didMove(toParent: self)
        self.safariViewController = newSafariViewController
    }
}
