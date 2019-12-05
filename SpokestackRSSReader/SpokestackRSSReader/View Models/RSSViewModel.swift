//
//  RSSViewModel.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

class RSSViewModel: ObservableObject {

    // MARK: Interneal (properties)
    
    @Published private (set) var feedItems: Array<RSSFeedItem> = [] {
        
        didSet {
            self.queuedItems = feedItems
        }
    }
    
    @Published private (set) var currentItem: RSSFeedItem?
    
    // MARK: Private (properties)
    
    private var processingCurrentItemDescription: Bool = false
    
    private var speechController: SpeechController = SpeechController()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var isFinished: Bool = false
    
    private var shouldAnnounceWelcome: Bool = true {
        
        didSet {
            
            if !shouldAnnounceWelcome {
    
                if !self.feedItems.isEmpty {
                    self.processHeadlines()
                }
            }
        }
    }
    
    private var queuedItems: Array<RSSFeedItem> = []
    
    // MARK: Initializers
    
    init() {}
    
    // MARK: Internal (methods)
    
    func readArticleDescription(_ description: String) -> Void {
        
        self.processingCurrentItemDescription = true
        self.speechController.respond(description)
    }
    
    func activateSpeech() -> Void {
        
        if self.shouldAnnounceWelcome {

            self.speechController.respond(App.welcomeMessage)
            self.load()

        } else {

            self.load()
        }

        self.speechController.textPublisher.sink( receiveCompletion: { _ in },
                                                  receiveValue: { [unowned self] value in
            
                                                    self.readArticleDescription(self.currentItem!.description)
        })
        .store(in: &self.subscriptions)
    }
    
    func deactiveSpeech() -> Void {
        self.speechController.deactivatePipelineASR()
    }
    
    // MARK: Private (methods)
    
    private func load() -> Void {
        
        let feedURL: URL = URL(string: App.Feed.feedURL)!
        let rssController: RSSController = RSSController(feedURL)
        
        rssController.parseFeed({feedItems in
            
            self.feedItems = feedItems
            self.shouldAnnounceWelcome.toggle()
        })
    }
    
    private func processHeadlines() -> Void {

        self.speechController.itemFinishedPublisher.sink(receiveCompletion: {_ in }, receiveValue: {value in

            self.processingCurrentItemDescription = false

            /// The "welcome" has finished playing, but none of the headlines  have been read if the feed items
            /// and the queued items are the same
            
            if self.feedItems.count == self.queuedItems.count {
                
                if let item: RSSFeedItem = self.queuedItems.first {

                    self.queuedItems.remove(at: 0)
                    self.currentItem = item
                    self.speechController.respond(item.title)
                }
                
            } else if !self.queuedItems.isEmpty {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + App.actionDelay, execute: {[unowned self] in
                  self.processNextItem()
                })
                
            } else {

                if !self.isFinished {
                
                    self.speechController.respond(App.finishedMessage)
                    self.isFinished.toggle()
                }
            }
            
        }).store(in: &self.subscriptions)
    }
    
    private func processNextItem() -> Void {
        
        if self.processingCurrentItemDescription {
            return
        }

        if let nextItem: RSSFeedItem = self.queuedItems.first {
   
             self.queuedItems.remove(at: 0)
             self.currentItem = nextItem
             self.speechController.respond(nextItem.title)
        }
    }
}

