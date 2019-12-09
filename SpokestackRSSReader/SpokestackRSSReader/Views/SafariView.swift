//
//  SafariView.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/25/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    
    // MARK: Internal (typealias)
    
    typealias UIViewControllerType = CustomSafariViewController

    // MARK: Internal (properties)
    
    var url: URL?

    // MARK: Internal (methods)
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> CustomSafariViewController {
        return CustomSafariViewController()
    }

    func updateUIViewController(_ safariViewController: CustomSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        safariViewController.url = url
    }
}
