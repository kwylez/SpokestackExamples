//
//  SpeechController.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/18/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import Spokestack

final class SpeechController: NSObject {
    
    // MARK: Private (properties)
    
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
    }
}

extension SpeechController: SpeechEventListener {
    func activate() {
        print("did activate")
    }
    
    func deactivate() {
        print("did deactivate")
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
