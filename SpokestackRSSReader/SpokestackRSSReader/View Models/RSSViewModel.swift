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
import UIKit

private let workItemQueue: DispatchQueue = DispatchQueue(label: "com.spokestack.workitem.queue")

enum RSSFeedItemTTSType {
    case headline, description
}

/// Transform RSSFeedItem  information into values that can be displayed on a view.
/// To aid in state management it is an `ObserverableObject`
class RSSViewModel: ObservableObject {

    // MARK: Interneal (properties)
    
    /// Read-only list of `RSSFeedItem`'s.
    /// It will be published to any subscribers
    @Published private (set) var feedItems: Array<RSSFeedItem> = []
    
    /// Optional `RSSFeedItem` instance
    /// It will be published to any subscribers
    @Published private (set) var currentItem: RSSFeedItem?
    
    // MARK: Private (properties)
    
    private var processedHeadlineURLS: Int = 0
    
    private var processedDescriptionURLS: Int = 0
    
    private var hasFinishedCachingHeadlineURLS: Bool {
        return self.feedItems.count == self.processedHeadlineURLS
    }
    
    private var hasFinishedCachingDescriptionURLS: Bool {
        return self.feedItems.count == self.processedDescriptionURLS
    }
    
    private var hasFinishedCachingURLS: Bool {
        return self.hasFinishedCachingHeadlineURLS && self.hasFinishedCachingDescriptionURLS
    }
    
    /// Whether or not the current item's description is being read
    private var processingCurrentItemDescription: Bool = false
    
    /// `SpeechController` instance
    private var speechController: SpeechController = SpeechController()
    
    /// Holds instances of `AnyCancellable` which will be cancled on deallocation
    private var subscriptions = Set<AnyCancellable>()
    
    /// `DispatchWorkItem` instance that is used to read the current item's desc.
    /// It will be cancelled and the next headline will be read if the time exceeds
    /// `App.actionDelay`
    private var workerItem: DispatchWorkItem!
    
    /// Whether or not the entire feed has finished processing. When `true` the `App.finishedMessage`
    /// is synthesized
    private var isFinished: Bool = false
    
    /// Whether or not  the `App.welcomeMessage` has not been synthensized. If it hasn't and the
    /// the `feedItems` property is not empty then call `processHeadlines`
    private var shouldAnnounceWelcome: Bool = true
    
    /// Array of `RSSFeedItem`'s. Once an an item has finished playing it is removed from
    /// the list.
    private var queuedItems: Array<RSSFeedItem> = []
    
    // MARK: Initializers
    
    init() {}
    
    // MARK: Internal (methods)
    
    /// Passes the rss feed item description to the speech controller for processing
    /// This will pause the next headline from being "read".
    /// - Parameter description: `RSSFeedItem.description`
    /// - Returns: Void
    func readArticleDescription(_ currentItem: RSSFeedItem) -> Void {
        
        guard let cachedURL: URL = currentItem.cachedDescriptionLink else {
            return
        }
        
        self.processingCurrentItemDescription = true
        self.speechController.play(cachedURL)
    }
    
    /// Handles the logic of announcing the welcome text, loading the feed and
    /// setting up the `speechController.textPublisher`
    /// - Returns: Void
    func activateSpeech() -> Void {

        self.load()
        self.speechController.textPublisher.sink( receiveCompletion: { _ in },
                                                  receiveValue: { [unowned self] value in
            
                                                    self.readArticleDescription(self.currentItem!)
        })
        .store(in: &self.subscriptions)
    }
    
    /// Deactivates the `speechController`'s pipleline ASR.
    /// - Returns: Void
    func deactiveSpeech() -> Void {
        self.speechController.deactivatePipelineASR()
    }
    
    // MARK: Private (methods)
    
    /// Loads / parses the rss feed
    /// - Returns: Void
    private func load() -> Void {
        
        let feedURL: URL = URL(string: App.Feed.feedURL)!
        let rssController: RSSController = RSSController(feedURL)

        self.cacheItems()
        self.processHeadlines()
        self.speechController.respond(App.welcomeMessage)
        
        rssController.parseFeed({[unowned self] feedItems in
            self.feedItems = feedItems
        })
    }
    
    private func cacheItems() -> Void {
        
        self.speechController.synthesizeFeedItemHasFinished
        .handleEvents(receiveSubscription: { _ in
          print("Network request will start")
        }, receiveOutput: { output in
          print("Network request data received \(output)")
        }, receiveCancel: {
          print("Network request cancelled")
        })
        .print("fetch publisher")
        .receive(on: RunLoop.main)
        .sink(receiveValue: {[unowned self] feedItem in
            
            if !self.hasFinishedCachingHeadlineURLS {
            
                if let indexOfFeedItem: Int = self.feedItems.firstIndex(where: { $0.id == feedItem.id }) {
                    print("what is index for desc \(indexOfFeedItem) and feed id \(feedItem.id)")
                    self.feedItems[indexOfFeedItem] = feedItem
                }

                self.processedHeadlineURLS += 1
                self.processNextHeadline()

                if self.hasFinishedCachingHeadlineURLS {
                    self.initiateDescriptionCaching()
                }
                
                return
            }
            
            if !self.hasFinishedCachingDescriptionURLS {

                if let indexOfFeedItem: Int = self.feedItems.firstIndex(where: { $0.id == feedItem.id }) {
                    self.feedItems[indexOfFeedItem] = feedItem
                }

                self.processedDescriptionURLS += 1
                self.processNextDescription()

                if self.hasFinishedCachingURLS {
                    self.startPlayback()
                }

                return
            }
        })
        .store(in: &self.subscriptions)
    }
    
    private func processNextHeadline() -> Void {
        
        if self.processedHeadlineURLS < self.feedItems.count {
            self.speechController.fetchTTSFile(self.feedItems[self.processedHeadlineURLS], itemTTSType: .headline)
        }
    }
    
    private func processNextDescription() -> Void {
        
        if self.processedDescriptionURLS < self.feedItems.count {
            self.speechController.fetchTTSFile(self.feedItems[self.processedDescriptionURLS], itemTTSType: .description)
        }
    }
    
    private func startPlayback() -> Void {
        
        self.queuedItems = self.feedItems
        
        if self.feedItems.count == self.queuedItems.count {

            if let item: RSSFeedItem = self.queuedItems.first,
                let headlineURL: URL = item.cachedHeadlineLink {

                self.queuedItems.remove(at: 0)
                self.currentItem = item
                self.speechController.play(headlineURL)
            }
        }
    }
    
    private func initiateHeadlineCaching() -> Void {

        let firstItemIndex: Int = 0
        self.speechController.fetchTTSFile(self.feedItems[firstItemIndex], itemTTSType: .headline)
    }
    
    private func initiateDescriptionCaching() -> Void {

        let firstItemIndex: Int = 0
        self.speechController.fetchTTSFile(self.feedItems[firstItemIndex], itemTTSType: .description)
    }
    
    /// Processes each headline after it has finished playing
    /// It is called after the `shouldAnnounceWelcome` has been set to false
    /// - Returns: Void
    private func processHeadlines() -> Void {

        UIApplication.shared.isIdleTimerDisabled = true

        self.speechController.itemFinishedPublisher
            .sink(receiveCompletion: {_ in }, receiveValue: {value in

            self.processingCurrentItemDescription = false

            /// The "welcome" has finished playing, but none of the headlines  have been read if the feed items
            /// and the queued items are the same

            if !self.queuedItems.isEmpty {

                self.workerItem = DispatchWorkItem { [weak self] in

                    guard let strongSelf = self else {
                        return
                    }

                    if !strongSelf.workerItem.isCancelled {
                        strongSelf.speechController.activatePipelineASR()
                    } else {
                        strongSelf.speechController.stop()
                    }

                    self?.workerItem = nil
                }

                workItemQueue.async(execute: self.workerItem)
                workItemQueue.asyncAfter(deadline: .now() + App.actionDelay) {[weak self] in

                    DispatchQueue.main.async {
                        self?.workerItem?.cancel()
                        self?.processNextItem()
                    }
                }

            } else if !self.hasFinishedCachingHeadlineURLS {

                self.initiateHeadlineCaching()

            } else {
             
                if self.queuedItems.isEmpty && !self.isFinished {
                    
                    UIApplication.shared.isIdleTimerDisabled = false
                    
                    self.deactiveSpeech()
                    self.speechController.respond(App.finishedMessage)
                }
            }
        })
        .store(in: &self.subscriptions)

        self.speechController.synthesizeHasFinished.sink(receiveValue: {url in

            self.speechController.play(url)
            
            if self.shouldAnnounceWelcome {

                self.speechController.play(url)
                self.shouldAnnounceWelcome.toggle()

                return
            }

            if !self.isFinished {
                self.isFinished.toggle()
            }
        })
        .store(in: &self.subscriptions)
    }
    
    /// Handles processing the next `RSSFeedItem` in the `queuedItems`
    /// if there is one
    /// - Returns: Void
    private func processNextItem() -> Void {
        
        if self.processingCurrentItemDescription {
            return
        }

        if let nextItem: RSSFeedItem = self.queuedItems.first,
            let headlineURL: URL = nextItem.cachedHeadlineLink {
            
            self.queuedItems.remove(at: 0)
            self.currentItem = nextItem
            self.speechController.play(headlineURL)

        }
    }
}

