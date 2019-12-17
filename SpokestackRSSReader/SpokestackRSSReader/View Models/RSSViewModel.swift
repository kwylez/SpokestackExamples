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
    
    // MARK: Private (properties)
    
    /// Gives a count of how many headline texts that have been processed
    private var processedHeadlineURLS: Int = 0
    
    /// Gives a count of how many description texts that have been processed
    private var processedDescriptionURLS: Int = 0
    
    /// Computed propery that returns true if the `feedItems.count` and
    /// `processedHeadlineURLS` are the same
    private var hasFinishedCachingHeadlineURLS: Bool {
        return self.feedItems.count == self.processedHeadlineURLS
    }
    
    /// Computed propery that returns true if the `feedItems.count` and
    /// `processedDescriptionURLS` are the same
    private var hasFinishedCachingDescriptionURLS: Bool {
        return self.feedItems.count == self.processedDescriptionURLS
    }
    
    /// Computed propery that returns true if  `hasFinishedCachingHeadlineURLS` and
    /// `hasFinishedCachingDescriptionURLS` are the same
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

//        self.cacheItems()
//        self.processHeadlines()
//        self.speechController.respond(App.welcomeMessage)
        
        rssController.parseFeed({[unowned self] feedItems in
            self.feedItems = feedItems
            self.queuedDescriptions()
        })
    }
    
    private func queuedDescriptions() -> Void {
        
        self.speechController
            .processFeedItemsPublisher(self.feedItems)
            .receive(on: RunLoop.main)
            .handleEvents(receiveSubscription: { _ in
              print("Network request will start")
            }, receiveOutput: { _ in
              print("Network request data received")
            }, receiveCancel: {
              print("Network request cancelled")
            })
            .sink(receiveCompletion: { print($0) },
                  receiveValue: { value in
                    print("what is the final value queuedDescriptions \(value)")
            })
            .store(in: &self.subscriptions)
        
//        let ttsInputs: Array<TextToSpeechInput> = self.feedItems.map{ TextToSpeechInput($0.description) }
//        print("ttsInputs \(ttsInputs)")
//        self.speechController
//            .queuedController
//            .synthesize(ttsInputs)
//            .receive(on: RunLoop.main)
//            .handleEvents(receiveSubscription: { _ in
//              print("Network request will start")
//            }, receiveOutput: { _ in
//              print("Network request data received")
//            }, receiveCancel: {
//              print("Network request cancelled")
//            })
//            .sink(receiveCompletion: { print($0) },
//                  receiveValue: { value in
//                    print("what is the final value queuedDescriptions \(value)")
//            })
//            .store(in: &self.subscriptions)
    }
    
    /// Sets up subscriber to handle received cached item events from the
    /// `SpeechController.synthesizeFeedItemHasFinished`
    /// publisher
    /// - Returns: Void
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
        .sink(receiveCompletion: {completion in

            switch completion {
                case .finished:
                    break
                case .failure(let anError):
                    print("received error: ", anError)
            }
            
        },receiveValue: {[unowned self] feedItem in
            
            /// First check to see if the headlines have finished processing
            /// if they aren't then process the next headline
            
            if !self.hasFinishedCachingHeadlineURLS {
            
                if let indexOfFeedItem: Int = self.feedItems.firstIndex(where: { $0.id == feedItem.id }) {
                    self.feedItems[indexOfFeedItem] = feedItem
                }

                self.processedHeadlineURLS += 1
                self.processNextHeadline()

                /// Once the headline are done caching, initiate the description caching
                
                if self.hasFinishedCachingHeadlineURLS {
                    self.initiateDescriptionCaching()
                }
                
                return
            }
            
            /// If the descriptions haven't finished caching then process the next
            /// one. Once they are finished then start playback
            
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
    
    /// If `processedHeadlineURLS`  is less than the number of `feedItems`
    /// then the next headline will be processed by the `speechController` instance
    /// - Returns: Void
    private func processNextHeadline() -> Void {
        
        if self.processedHeadlineURLS < self.feedItems.count {
            self.speechController.fetchTTSFile(self.feedItems[self.processedHeadlineURLS], itemTTSType: .headline)
        }
    }
    /// If `processedHeadlineURLS`  is less than the number of `feedItems`
    /// then the next headline will be processed by the `speechController` instance
    /// - Returns: Void
    private func processNextDescription() -> Void {
        
        if self.processedDescriptionURLS < self.feedItems.count {
            self.speechController.fetchTTSFile(self.feedItems[self.processedDescriptionURLS], itemTTSType: .description)
        }
    }
    
    /// Starts playback of the `feedItems`
    /// - Returns: Void
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
    
    /// Fetches the TTS file for the first `RSSFeedItem`'s headline
    /// - Returns: Void
    private func initiateHeadlineCaching() -> Void {

        let firstItemIndex: Int = 0
        self.speechController.fetchTTSFile(self.feedItems[firstItemIndex], itemTTSType: .headline)
    }

    /// Fetches the TTS file for the first `RSSFeedItem`'s description
    /// - Returns: Void
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

                /// The work item is what will  handle activating the pipleline's ASR
                /// if after the `App.actionDelay` value and it hasn't been activated
                /// then the next item will be processed

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

                /// Execute the `workerItem`

                workItemQueue.async(execute: self.workerItem)
                workItemQueue.asyncAfter(deadline: .now() + App.actionDelay) {[weak self] in

                    DispatchQueue.main.async {
                        self?.workerItem?.cancel()
                        self?.processNextItem()
                    }
                }

            } else if !self.hasFinishedCachingHeadlineURLS {

                /// Process the headline caching
                
                self.initiateHeadlineCaching()

            } else {
             
                /// If the `queuedItems` is finished, but the `App.finishedMessage`
                /// hasn't been processed the turn on screen dimming (`UIApplication.shared.isIdleTimerDisabled`)
                /// deactivate speech and have the `speechController`
                /// respond to the `App.finishedMessage`

                if self.queuedItems.isEmpty && !self.isFinished {
                    
                    UIApplication.shared.isIdleTimerDisabled = false
                    
                    self.deactiveSpeech()
                    self.speechController.respond(App.finishedMessage)
                }
            }
        })
        .store(in: &self.subscriptions)

        /// Subscriber that will handle when a synthesize item has finished and the `URL` has
        /// been received
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

