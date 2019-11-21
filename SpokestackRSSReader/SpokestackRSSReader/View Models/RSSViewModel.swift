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
    
    @Published private (set) var feedItems: Array<RSSFeedItem> = []
    
    // MARK: Private (properties)
    
    private var speechController: SpeechController = SpeechController()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let subscriber: SpeechControllerTranscriptSubscriber = SpeechControllerTranscriptSubscriber()
    
    // MARK: Initializers
    
    init() {
        speechController.subject.subscribe(self.subscriber)
    }
    
    // MARK: Internal (methods)
    
    func activatePipeline() -> Void {

        self.speechController.start()
        self.speechController.subject.sink( receiveCompletion: { [unowned self] completion in

            self.speechController.stop()

        }, receiveValue: { [unowned self] value in
            
            self.load()
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
            self.processSpeech()
        })
    }
    
    private func processSpeech() -> Void {

        self.feedItems.forEach {
            self.speechController.respond($0.title)
        }
    }
}

