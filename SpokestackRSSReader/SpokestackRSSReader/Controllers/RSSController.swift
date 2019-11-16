//
//  RSSController.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import FeedKit

class RSSController {
    
    // MARK: Private (properties)
    
    private var feedURL: URL
    
    // MARK: Initializers
    
    init(_ url: URL) {
        self.feedURL = url
    }
    
    // MARK: Internal (methods)
    
    func parseFeed() -> Void {
        
        let parser = FeedParser(URL: self.feedURL)
        
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) {result in
            
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let feed):
                    print("what is my feed \(feed)")
                    
                    switch feed {
                        case .atom(let atomFeed):
                        break
                        case .rss(let rssFeed):
                        break
                        case .json(let jsonFeed):
                        break
                    }
                    
                    break
                case .failure(let error):
                    print("is there an error \(error)")
                    break
                }
            }
        }
    }
}
