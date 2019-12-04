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
 
    @Published private (set) var isValidImage: Bool = false
    
    private (set) var image: UIImage = UIImage()
    
    // MARK: Private (properties)
    
    private var cancellable: AnyCancellable?
    
    deinit {
        cancellable?.cancel()
    }
    
    init(){}
    
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
        .sink( receiveCompletion: { completion in
            
            switch completion {
            case .failure(_):
                self.isValidImage = false
                break
            default:
                break
            }
            
        }, receiveValue: { [unowned self] image in

            if let image = image {
                
                self.image = image
                self.isValidImage = true
                
            } else {
                
                self.isValidImage = false
            }
        })
    }
}
