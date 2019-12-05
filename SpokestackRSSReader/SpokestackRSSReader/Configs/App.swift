//
//  App.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/20/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation

struct App {

    static let welcomeMessage: String = "Welcome to the latest TechCrunch Headlines"
    
    static let actionDelay: TimeInterval = 1.5
    
    static let actionPhrase: String = "Tell me more"
    
    static let finishedMessage: String = "You're all caught up"
    
    struct Feed {
        
        static let heading: String = "TechCrunch"
        
        static let feedURL: String = "https://feeds.feedburner.com/TechCrunch/"
    }
}
