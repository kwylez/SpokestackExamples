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

private let workItemQueue: DispatchQueue = DispatchQueue(label: "com.spokestack.workitem.queue")

class RSSViewModel: ObservableObject {

    // MARK: Interneal (properties)
    
    @Published private (set) var feedItems: Array<RSSFeedItem> = [] {
        
        didSet {
            self.queuedItems = feedItems
        }
    }
    
    @Published private (set) var currentItem: RSSFeedItem?
    
    // MARK: Private (properties)
    
    private var speechController: SpeechController = SpeechController()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var item: DispatchWorkItem!
    
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
        self.speechController.respond(description)
    }
    
    func activatePipeline() -> Void {
        
        if self.shouldAnnounceWelcome {

            self.speechController.respond(App.welcomeMessage)
            self.load()

        } else {

            self.load()
        }

        self.speechController.textPublisher.sink( receiveCompletion: { [unowned self] completion in

            self.speechController.stop()

        }, receiveValue: { [unowned self] value in
            print("what is textPublisher value \(value)")
            self.readArticleDescription(self.currentItem!.description)
        })
        .store(in: &self.subscriptions)
    }
    
    func deactivePipeline() -> Void {
        self.speechController.stop()
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

            /// The "welcome" has finished playing, but none of the headlines  have been read if the feed items
            /// and the queued items are the same
            
            if self.feedItems.count == self.queuedItems.count {
                
                if let item: RSSFeedItem = self.queuedItems.first {

                    self.queuedItems.remove(at: 0)
                    self.currentItem = item
                    self.speechController.respond(item.title)
                }
                
            } else if !self.queuedItems.isEmpty {
                
                self.item = DispatchWorkItem { [weak self] in
                    
                    guard let strongSelf = self else {
                        print("FAIL ON STRONG SELF")
                        return
                    }
                    
                    if !strongSelf.item.isCancelled {
                        print("Not cancelled so start")
                        strongSelf.speechController.activatePipelineASR()
                    } else {
                        strongSelf.speechController.stop()
                    }
                    
                    self?.item = nil
                }

                workItemQueue.async(execute: self.item)
                workItemQueue.asyncAfter(deadline: .now() + 5.5) {[weak self] in
                    print("I should be cancelling the speech controller")
                    self?.item?.cancel()
                    self?.processNextItem()
                }

            } else {

                self.speechController.respond(App.finishedMessage)
            }
            
        }).store(in: &self.subscriptions)
        
        /// Read article after 1.5 seconds
        ///
        /// Should timer be instance var with no auto connect?
        /// That way after an item has finished, Start a new timer, active ASR, if found, then cancel timer, read description, shut down ASR  and then continue
        
//        self.timerCancellable = Timer.publish(every: 1.5, on: RunLoop.main, in: .common)
//        .autoconnect()
//        .sink { receivedTimeStamp in
//            print("passed through: ", receivedTimeStamp)
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.5) {
//
//            self.timerCancellable = Timer.publish(every: 1.5, on: RunLoop.main, in: .common)
//            .autoconnect()
//            .sink { receivedTimeStamp in
//                print("passed through 1111: ", receivedTimeStamp)
//            }
//        }
    }
    
    private func processNextItem() -> Void {
        
        self.speechController.stop()

        if let nextItem: RSSFeedItem = self.queuedItems.first {
   
             self.queuedItems.remove(at: 0)
             self.currentItem = nextItem
             self.speechController.respond(nextItem.title)
         }
    }
}

