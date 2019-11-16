//
//  Feed.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation

struct Feed: Identifiable {
    
    // MARK: Internal (properties)
    
    let id: UUID = UUID()
    
    let title: String
    
    let link: String
    
    let description: String
    
    let items: Array<FeedItem>
}
