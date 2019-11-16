//
//  RSSController.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import FeedKit

typealias RSSControllerParseCallback = (_ feedItems: Array<RSSFeedItem>) -> Void

class RSSController {
    
    // MARK: Private (properties)
    
    private var feedURL: URL
    
    // MARK: Initializers
    
    init(_ url: URL) {
        self.feedURL = url
    }
    
    // MARK: Internal (methods)
    
    func parseFeed(_ callback: @escaping RSSControllerParseCallback) -> Void {
        
        let parser = FeedParser(URL: self.feedURL)
        
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) {result in
            
            var feedItems: Array<RSSFeedItem> = []
                        
            switch result {
                
            case .success(let feed):

                switch feed {
                    case .atom(let atomFeed):
                        feedItems = atomFeed.convert()
                    break
                    case .rss(let rssFeed):
                        feedItems = rssFeed.convert()
                    break
                    case .json(let jsonFeed):
                        feedItems = jsonFeed.convert()
                    break
                }
                break
            default:
                break
            }
            
            DispatchQueue.main.async {
                callback(feedItems)
            }
        }
    }
}
