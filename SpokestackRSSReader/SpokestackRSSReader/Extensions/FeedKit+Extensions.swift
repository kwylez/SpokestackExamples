//
//  FeedKit+Extensions.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/16/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import FeedKit

extension RSSFeed {
    
    func convert() -> Array<RSSFeedItem> {
        
        var feedItems: Array<RSSFeedItem> = []

        self.items?.compactMap{ $0 }.forEach {rssFeedItem in

            let title: String = rssFeedItem.title ?? "Title N/A"
            let link: String = rssFeedItem.link ?? "Link N/A"
            let description: String = rssFeedItem.description ?? "Description N/A"
            
            let feedItem: RSSFeedItem = RSSFeedItem(title: title, link: link, description: description)
            feedItems.append(feedItem)
        }
        
        return feedItems
    }
}

extension JSONFeed {
    
    func convert() -> Array<RSSFeedItem> {
        
        var feedItems: Array<RSSFeedItem> = []

        self.items?.compactMap{ $0 }.forEach {rssFeedItem in
            
            let title: String = rssFeedItem.title ?? "Title N/A"
            let link: String = rssFeedItem.url ?? "Link N/A"
            let description: String = rssFeedItem.summary ?? "Description N/A"
            
            let feedItem: RSSFeedItem = RSSFeedItem(title: title, link: link, description: description)
            feedItems.append(feedItem)
        }
        
        return feedItems
    }
}

extension AtomFeed {
    
    func convert() -> Array<RSSFeedItem> {
        
        var feedItems: Array<RSSFeedItem> = []

        self.entries?.compactMap{ $0 }.forEach {rssFeedItem in
            
            let title: String = rssFeedItem.title ?? "Title N/A"
            let link: String = rssFeedItem.links?.first?.attributes?.href ?? "Link N/A"
            let description: String = rssFeedItem.summary?.value ?? "Description N/A"
            
            let feedItem: RSSFeedItem = RSSFeedItem(title: title, link: link, description: description)
            feedItems.append(feedItem)
        }
        
        return feedItems
    }
}
