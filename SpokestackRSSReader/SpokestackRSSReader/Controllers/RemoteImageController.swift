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
    
    let id: String = UUID().uuidString

    @Published private (set) var image: UIImage = RemoteImageController.defaultImage
    
    @Published private (set) var isValidImage: Bool = false
    
    // MARK: Private (properties)
    
    private static let defaultImage: UIImage = UIImage(named: "default-headline-image")!
    
    private var cancellable: AnyCancellable?
    
    deinit {
        cancellable?.cancel()
    }
    
    // MARK: Internal (methods)
    
    func fetch(_ url: String) -> Void {
        
        guard let url: URL = URL(string: url) else {
            return
        }
        
        cancellable?.cancel()
        
        let urlSession = URLSession.shared
        let urlRequest = URLRequest(url: url)
        
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
