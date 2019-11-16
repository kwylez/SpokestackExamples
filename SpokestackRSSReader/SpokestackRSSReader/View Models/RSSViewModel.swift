//
//  RSSViewModel.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import Combine

class RSSViewModel: ObservableObject {

    // MARK: Interneal (properties)
    
    @Published private (set) var feedItems: Array<RSSFeedItem> = []
    
    // MARK: Initializers
    
    init() {}
    
    // MARK: Internal (methods)
    
    func load() -> Void {
        
        let feedURL: URL = URL(string: "https://feeds.feedburner.com/TechCrunch/")!
        let rssController: RSSController = RSSController(feedURL)
        
        rssController.parseFeed()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            
            let items: Array<RSSFeedItem> = [
                RSSFeedItem(title: "Hello World",
                         link: "http://www.yahoo.com/",
                         description: "First Descriptions"),
                RSSFeedItem(title: "Hello World 2",
                         link: "http://www.google.com/",
                         description: "First Descriptions 2")
            ]
            
            self.feedItems = items
        }
    }
}
