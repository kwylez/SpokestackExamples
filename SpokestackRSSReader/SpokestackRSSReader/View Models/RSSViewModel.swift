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
import Spokestack

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
    
    @Published private (set) var actionButtonStatus: FloatingActionButtonStatus = .unknown
    
    // MARK: Private (properties)
    
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
    
    private var shouldAnnounceFinishMessage: Bool {
        self.queuedItems.isEmpty && !self.isFinished
    }
    
    /// Array of `RSSFeedItem`'s. Once an an item has finished playing it is removed from
    /// the list.
    private var queuedItems: Array<RSSFeedItem> = []
    
    private var processedDescriptions: Array<URL> = []
    
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
        
        self.setupSynthesizedHeadlinesSubscriber()

        rssController.parseFeed({[unowned self] feedItems in
            
            self.speechController.respond(App.welcomeMessage)
            self.feedItems = feedItems
        })
    }
    
    private func processFeedItems() -> Void {
        
           self.speechController
                .processFeedItemsDescriptionsPublisher(self.feedItems)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: {[unowned self] completion in

                    switch completion {

                    case .finished:
                        
                        self.finishProcessDescriptionLinks()
                        break
                    default: break
                    }
                },
                receiveValue: { urls in

                    self.processedDescriptions = urls
                })
                .store(in: &self.subscriptions)
    }
    
    private func finishProcessDescriptionLinks() -> Void {

        for (index, url) in self.processedDescriptions.enumerated() {
            
            var item: RSSFeedItem = self.feedItems[index]
            item.cachedDescriptionLink = url
            
            self.feedItems[index] = item
        }

        self.startPlayback()
    }
    
    /// Starts playback of the `feedItems`
    /// - Returns: Void
    private func startPlayback() -> Void {
        
        self.queuedItems = self.feedItems
        
        if self.queuedItems.count == self.feedItems.count {
        
            if let item: RSSFeedItem = self.queuedItems.first {

                self.queuedItems.remove(at: 0)
                self.currentItem = item
                self.speechController.respond(item.title)
                
                self.actionButtonStatus = .isPlaying
            }
        }
    }
    
    /// Processes each headline after it has finished playing
    /// It is called after the `shouldAnnounceWelcome` has been set to false
    /// - Returns: Void
    private func setupSynthesizedHeadlinesSubscriber() -> Void {

        UIApplication.shared.isIdleTimerDisabled = true

        self.speechController
            .itemFinishedPublisher
            .sink(receiveValue: {value in
                
            self.processingCurrentItemDescription = false

            /// The "welcome" has finished playing, but none of the headlines  have been read if the feed items
            /// and the queued items are the same

            if self.processedDescriptions.isEmpty {
                
                self.processFeedItems()
                
            } else if !self.queuedItems.isEmpty {

                /// The work item is what will  handle activating the pipleline's ASR
                /// if after the `App.actionDelay` value and it hasn't been activated
                /// then the next item will be processed

                self.workerItem = DispatchWorkItem { [weak self] in

                    guard let strongSelf = self else {
                        return
                    }

                    DispatchQueue.main.async {
                        strongSelf.actionButtonStatus = .isListening
                    }
                    
                    if !strongSelf.workerItem.isCancelled {
                        strongSelf.speechController.activatePipelineASR()
                    } else {
                        strongSelf.speechController.stop()
                    }

                    self?.workerItem = nil
                }

                /// Execute the `workerItem`

                workItemQueue.async(execute: self.workerItem)
                workItemQueue.asyncAfter(deadline: .now() + App.actionDelay) {[weak self] in

                    DispatchQueue.main.async {

                        self?.actionButtonStatus = .isPaused
                        self?.speechController.activatePipelineASR()
                        self?.workerItem?.cancel()
                        self?.processNextItem()
                    }
                }

            } else {

                if self.shouldAnnounceFinishMessage {

                     UIApplication.shared.isIdleTimerDisabled = false

                     self.actionButtonStatus = .isPaused
                     self.isFinished.toggle()
                     self.deactiveSpeech()
                     self.speechController.respond(App.finishedMessage)
                 }
            }
        })
        .store(in: &self.subscriptions)
        
        /// Subscriber that will handle when a synthesize item has finished and the `URL` has
        /// been received
        self.speechController.synthesizeHasFinished
            .receive(on: RunLoop.main)
            .sink(receiveValue: {url in

                self.speechController.play(url)
                    
                if self.shouldAnnounceWelcome {

                    self.shouldAnnounceWelcome.toggle()
                    return
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

        if let nextItem: RSSFeedItem = self.queuedItems.first {
            
            self.queuedItems.remove(at: 0)
            self.currentItem = nextItem
            self.speechController.respond(nextItem.title)
            
            self.actionButtonStatus = .isPlaying
        }
    }
}

