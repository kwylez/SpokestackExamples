//
//  RSSController.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import FeedKit

/// Typealias for callback signature that is invoked after a feed is parsed

typealias RSSControllerParseCallback = (_ feedItems: Array<RSSFeedItem>) -> Void

/// Controller class for controlling an RSS feed
class RSSController {
    
    // MARK: Private (properties)

    /// URL of RSS feed
    private var feedURL: URL
    
    // MARK: Initializers

    /// Initializer
    /// - Parameter url: URL of the RSS feed
    init(_ url: URL) {
        self.feedURL = url
    }
    
    // MARK: Internal (methods)
    
    /// Using a global dispatch queue this method asynchronously parses the feed
    /// and will return an array of `RSSFeedItem`'s on the main queue
    /// - Parameter callback: RSSControllerParseCallback
    /// - Returns: Void
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
                
                let endIndex: Int = App.Feed.numberOfItemsToDisplay - 1
                let feedRange: ArraySlice<RSSFeedItem> = feedItems[0...endIndex]
                let items: Array<RSSFeedItem> = Array(feedRange)
                
                callback(items)
            }
        }
    }
}
