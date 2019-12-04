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
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

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
    
    let textPublisher = PassthroughSubject<String, Never>()
    
    let itemFinishedPublisher = PassthroughSubject<AVPlayerItem, Never>()
    
    // MARK: Private (properties)
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let avSpeechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    private var player: AVPlayer = AVPlayer()
    
    private var tts: TextToSpeech?
    
    private var queued: Array<AVPlayerItem> = []
    
    private var transcript: String = "" {
        
        didSet {
            transcript = transcript.lowercased()
        }
    }
    
    lazy private var pipeline: SpeechPipeline = {

        let c = SpeechConfiguration()
        let filterPath = Bundle(for: type(of: self)).path(forResource: c.filterModelName, ofType: "lite")!
        c.filterModelPath = filterPath
       
        let encodePath = Bundle(for: type(of: self)).path(forResource: c.encodeModelName, ofType: "lite")!
        c.encodeModelPath = encodePath
        
        let detectPath = Bundle(for: type(of: self)).path(forResource: c.detectModelName, ofType: "lite")!
        c.detectModelPath = detectPath
        c.tracing = Trace.Level.PERF
       
        return SpeechPipeline(SpeechProcessors.appleSpeech.processor,
                             speechConfiguration: c,
                             speechDelegate: self,
                             wakewordService: SpeechProcessors.appleWakeword.processor,
                             pipelineDelegate: self)
    }()
    
    // MARK: Initializers
    
    deinit {
        pipeline.speechDelegate = nil
    }
    
    override init() {
        
        super.init()
        
        avSpeechSynthesizer.delegate = self
        tts = TextToSpeech(self, configuration: SpeechConfiguration())
    }
    
    // MARK: Internal (methods)
    
    func start() -> Void {
        self.pipeline.start()
    }
    
    func stop() -> Void {
        self.pipeline.stop()
    }
    
    func activatePipelineASR() -> Void {
        self.pipeline.activate()
    }
    
    func deactivatePipelineASR() -> Void {
        self.pipeline.deactivate()
    }
    
    func respond(_ text: String) -> Void {

        let input = TextToSpeechInput(text)
        self.tts?.synthesize(input)
    }
    
    // MARK: Private (methods)
    
    private func parse() -> Void {

        if self.transcript.contains(App.actionPhrase.lowercased()) {
            print("should be parsing....")
            self.textPublisher.send(self.transcript)
            self.stop()
        }
    }
    
    private func playOrQueueIfNecessary(_ playerItem: AVPlayerItem) -> Void {

        /// Set the appropriate audio session
        
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        self.player = AVPlayer(playerItem: playerItem)
        self.player.play()
        self.listenToNotification(playerItem)
    }
    
    private func listenToNotification(_ playerItem: AVPlayerItem) -> Void {
        
        let _ = NotificationCenter.default
            .publisher(for: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            .map({ $0.object as! AVPlayerItem })
            .sink(
                receiveCompletion: {_ in },
                receiveValue: { value in
                    
                    print("what is my value \(String(describing: value))")
                    
                    /// Need to send something more relevant or just letting subscriber know it is finished
                    /// You can't just send the status or you'll only receive one value

                    self.itemFinishedPublisher.send(value)
                }
            )
            .store(in: &self.subscriptions)
    }
}

extension SpeechController: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("sp did start \(utterance)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("sp did finish \(utterance)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("sp did pause \(utterance)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("sp did continue \(utterance)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("sp did cancel \(utterance)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print("sp willSpeakRangeOfSpeechString \(utterance)")
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

extension SpeechController: TextToSpeechDelegate {
    
    func success(url: URL) {

        let playerItem = AVPlayerItem(url: url)
        self.playOrQueueIfNecessary(playerItem)
    }
    
    func failure(error: Error) {
        print(error)
    }
}
