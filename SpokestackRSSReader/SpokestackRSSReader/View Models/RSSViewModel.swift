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
    
    var feed: String = "https://feeds.feedburner.com/TechCrunch/"
    
    @Published private (set) var feedItems: Array<RSSFeedItem> = []
    
    // MARK: Private (properties)
    
    private var speechController: SpeechController = SpeechController()
    
    // MARK: Initializers
    
    deinit {
        speechController.delegate = nil
    }
    
    init() {
        speechController.delegate = self
    }
    
    // MARK: Internal (methods)
    
    func activatePipeline() -> Void {
        self.speechController.start()
    }
    
    func deactivePipeline() -> Void {
        self.speechController.stop()
    }
    
    // MARK: Private (methods)
    
    private func load() -> Void {
        
        let feedURL: URL = URL(string: self.feed)!
        let rssController: RSSController = RSSController(feedURL)
        
        rssController.parseFeed({feedItems in
            self.feedItems = feedItems
        })
    }
}

extension RSSViewModel: SpeechControllerDelegate {
    
    func didFindResult(_ text: String, controller: SpeechController) {
        print("text \(text) and controller \(controller)")
        self.load()
    }
}
