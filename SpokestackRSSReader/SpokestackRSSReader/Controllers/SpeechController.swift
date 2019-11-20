//
//  SpeechController.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/18/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import Spokestack
import Combine

final class SpeechControllerTranscriptSubscriber: Subscriber {
    
    typealias Input = String
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        
        print("received on custom subscriber \(input)")
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("completion in the subscriber")
    }
}

final class SpeechController: NSObject {
    
    // MARK: Internal (properties)
    
    let subject = PassthroughSubject<String, Never>()
    
    // MARK: Private (properties)
    
    private var transcript: String = "" {
        
        didSet {
            transcript = transcript.lowercased()
        }
    }
    
    lazy private var pipeline: SpeechPipeline = {
    
       let speechPipeline = SpeechPipeline(SpeechProcessors.tfLiteWakeword.processor,
        speechConfiguration: SpeechConfiguration(),
        speechDelegate: self,
        wakewordService: SpeechProcessors.appleSpeech.processor,
        pipelineDelegate: self)
        
        return speechPipeline
    }()
    
    // MARK: Initializers
    
    deinit {
        pipeline.speechDelegate = nil
    }
    
    override init() {
        super.init()
    }
    
    // MARK: Internal (methods)
    
    func start() -> Void {
        self.pipeline.start()
    }
    
    func stop() -> Void {
        
        self.pipeline.stop()
        self.subject.send(completion: .finished)
    }
    
    // MARK: Private (methods)
    
    private func parse() -> Void {

        /// Read my latest TechCrunch news

        let pattern = #"""
        (read|what|mark \h as \h read).*(latest|oldest)\s(tech\s?crunch|cnn|seen \h the \h news)
        """#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return
        }
        
        let nsrange: NSRange = NSRange(self.transcript.startIndex..<self.transcript.endIndex, in: self.transcript)
        let nsText: NSString = self.transcript as NSString
        
        regex.enumerateMatches(in: self.transcript, options: [], range: nsrange) { result, flags, stop in
                            
                            guard let result = result else {
                                return
                            }
                            
                            let range = result.range
                            let foundText = nsText.substring(with: range)
                            self.subject.send(foundText)
        }
    }
}

extension SpeechController: SpeechEventListener {
    
    func activate() {
        print("did activate")
    }
    
    func deactivate() {
        print("did deactivate \(self.transcript)")
        self.transcript = ""
    }
    
    func didError(_ error: Error) {
        print("did didError \(error)")
    }
    
    func didTrace(_ trace: String) {
        print("did trace \(trace)")
    }
    
    func didStop() {
        print("didStop")
    }
    
    func didStart() {
        print("didStart")
    }
    
    func didRecognize(_ result: SpeechContext) {
        
        print("didRecognize \(result.isSpeech) and transscript \(result.transcript)")
        self.transcript = result.transcript
        self.parse()
    }
    
    func didTimeout() {
        print("didTimeout")
    }
}

extension SpeechController: PipelineDelegate {
    
    func didInit() {
        print("didInit")
    }
    
    func setupFailed(_ error: String) {
        print("error \(error)")
    }
}
