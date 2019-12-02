//
//  FeedItem.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import FeedKit

struct RSSFeedItem: Identifiable {
    
    // MARK: Internal (properties)
    
    let id: UUID = UUID()
    
    let publishedDate: Date
    
    let title: String
    
    let link: String
    
    let description: String
}

