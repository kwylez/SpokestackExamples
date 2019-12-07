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
    
    /// Maps instances of `FeedKit.RSSFeed` to `RSSFeedItem`
    /// - Returns:  Array<RSSFeedItem>
    func convert() -> Array<RSSFeedItem> {
        
        var feedItems: Array<RSSFeedItem> = []

        self.items?.compactMap{ $0 }.forEach {rssFeedItem in

            let title: String = rssFeedItem.title ?? "Title N/A"
            let link: String = rssFeedItem.link ?? "Link N/A"
            let description: String = rssFeedItem.description ?? "Description N/A"
            let publishedDate: Date = rssFeedItem.pubDate ?? Date()
            let imageLink: String = ""
            
            let feedItem: RSSFeedItem = RSSFeedItem(publishedDate: publishedDate,
                                                    title: title,
                                                    link: link,
                                                    description: description,
                                                    imageLink: imageLink)
            feedItems.append(feedItem)
        }
        
        return feedItems
    }
}

extension JSONFeed {
    
    /// Maps instances of `JSONFeed.RSSFeed` to `RSSFeedItem`
    /// - Returns:  Array<RSSFeedItem>
    func convert() -> Array<RSSFeedItem> {
        
        var feedItems: Array<RSSFeedItem> = []

        self.items?.compactMap{ $0 }.forEach {rssFeedItem in
            
            let title: String = rssFeedItem.title ?? "Title N/A"
            let link: String = rssFeedItem.url ?? "Link N/A"
            let description: String = rssFeedItem.summary ?? "Description N/A"
            let publishedDate: Date = rssFeedItem.datePublished ?? Date()
            let imageLink: String = rssFeedItem.image ?? ""
            
            let feedItem: RSSFeedItem = RSSFeedItem(publishedDate: publishedDate,
                                                    title: title,
                                                    link: link,
                                                    description: description,
                                                    imageLink: imageLink)
            feedItems.append(feedItem)
        }
        
        return feedItems
    }
}

extension AtomFeed {

    /// Maps instances of `AtomFeed.RSSFeed` to `RSSFeedItem`
    /// - Returns:  Array<RSSFeedItem>
    func convert() -> Array<RSSFeedItem> {
        
        var feedItems: Array<RSSFeedItem> = []

        self.entries?.compactMap{ $0 }.forEach {rssFeedItem in
            
            let title: String = rssFeedItem.title ?? "Title N/A"
            let link: String = rssFeedItem.links?.first?.attributes?.href ?? "Link N/A"
            let description: String = rssFeedItem.summary?.value ?? "Description N/A"
            let publishedDate: Date = rssFeedItem.published ?? Date()
            let imageLink: String = rssFeedItem.media?.mediaThumbnails?.first?.attributes?.url ?? ""
            
            let feedItem: RSSFeedItem = RSSFeedItem(publishedDate: publishedDate,
                                                    title: title,
                                                    link: link,
                                                    description: description,
                                                    imageLink: imageLink)
            feedItems.append(feedItem)
        }
        
        return feedItems
    }
}
