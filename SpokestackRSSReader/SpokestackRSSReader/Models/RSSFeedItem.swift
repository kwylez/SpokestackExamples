//
//  FeedItem.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import FeedKit

/// Model which represents a Feed Item
struct RSSFeedItem: Identifiable {
    
    // MARK: Internal (properties)
    
    /// Identifer for object. See `Identifiable`
    let id: UUID = UUID()
    
    /// The date the item was published
    let publishedDate: Date
    
    /// The title of the article
    let title: String
    
    /// Link to the aritcle
    let link: String
    
    /// Summary provided for the item
    let description: String
    
    /// Link to an image that represents the article.
    /// The default is "" because on `JSONFeed` supports this property
    let imageLink: String
}

