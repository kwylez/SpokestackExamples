//
//  RemoteImageController.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 12/4/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import Combine
import UIKit

final class RemoteImageController: ObservableObject {

    /// Current image set by the controller
    /// It defaults to the `RemoteImageController.defaultImage`
    private (set) var image: UIImage = RemoteImageController.defaultImage
    
    /// Published boolean property for whether or not the requested image is valid
    @Published private (set) var isValidImage: Bool = false
    
    // MARK: Private (properties)
    
    /// Default headline image
    private static let defaultImage: UIImage = UIImage(named: "default-headline-image")!
    
    /// Optional instance of a cancellable publisher
    private var cancellable: AnyCancellable?
    
    deinit {
        cancellable?.cancel()
    }
    
    // MARK: Internal (methods)
    
    /// Fetches an image for the given URL
    /// - Parameter url: The image url
    /// - Returns: Void
    func fetch(_ url: String) -> Void {
        
        guard let url: URL = URL(string: url) else {
            return
        }
        
        cancellable?.cancel()
        
        let urlSession: URLSession = URLSession.shared
        let urlRequest: URLRequest = URLRequest(url: url)
        
        /// Using the `dataTaskPublisher` make a request for the image
        /// map the data to an image, finally set the image, if found, and set the flag
        /// for the `isValidImage`.
        ///
        /// Once the `isValidImage` value is set it will be published to any subscribers
        
        cancellable = urlSession.dataTaskPublisher(for: urlRequest)
        .map { UIImage(data: $0.data) }
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: {_ in }, receiveValue: { image in

            if let image = image {
                
                self.image = image
                self.isValidImage = true
                
            } else {
                
                self.isValidImage = false
            }
        })
    }
}
