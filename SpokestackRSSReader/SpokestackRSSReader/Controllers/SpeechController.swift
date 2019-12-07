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

/// Controller class for controlling an RSS feed
final class SpeechController: NSObject {
    
    // MARK: Internal (properties)
    
    /// Subject that publishes the transcriped text to any subscribers
    let textPublisher = PassthroughSubject<String, Never>()
    
    /// Subject that publishes the `AVPlayerItem` that finished playing to any subscribers
    let itemFinishedPublisher = PassthroughSubject<AVPlayerItem, Never>()
    
    // MARK: Private (properties)
    
    /// Holds a references to any of the publishers to be cancelled during
    /// deallocation
    private var subscriptions = Set<AnyCancellable>()
    
    /// `AVPlayer` instance that will handle playback for the mp3
    private var player: AVPlayer = AVPlayer()
    
    /// Optional instance of `TextToSpeech`
    private var tts: TextToSpeech?
    
    /// Holds an array of `AVPlayerItem`'s that are waiting to be processeed
    /// Once an item has finished playing it is removed from the queue
    private var queued: Array<AVPlayerItem> = []
    
    /// Utterance that comes back from the ASR
    /// All values are lowercased
    private var transcript: String = "" {
        
        didSet {
            transcript = transcript.lowercased()
        }
    }
    
    /// This is the primary client entry point to the SpokeStack framework.
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
    
    /// Sets pipeline delegate to nil
    deinit {
        pipeline.speechDelegate = nil
    }
    
    /// Initializes `tts` by setting this class as it's delegate and default `SpeechConfiguration`
    override init() {
        
        super.init()
        tts = TextToSpeech(self, configuration: SpeechConfiguration())
    }
    
    // MARK: Internal (methods)
    
    /// Starts the `SpeechPipeline`
    /// - Returns: Void
    func start() -> Void {
        self.pipeline.start()
    }
    
    /// Stops the `SpeechPipeline`
    /// - Returns: Void
    func stop() -> Void {
        self.pipeline.stop()
    }
    
    /// Directly activates the `SpeechPipeline`'s Automatic Speech Recognizer (ASR)
    /// - Returns: Void
    func activatePipelineASR() -> Void {
        self.pipeline.activate()
    }

    /// Directly de-activates the `SpeechPipeline`'s Automatic Speech Recognizer (ASR)
    /// - Returns: Void
    func deactivatePipelineASR() -> Void {
        self.pipeline.deactivate()
    }
    
    /// Passes the text  to the `TextToSpeech` instance for synthesizing
    /// - Parameter text: Veribage that is expected to be synthesized and read back
    func respond(_ text: String) -> Void {

        let input = TextToSpeechInput(text)
        self.tts?.synthesize(input)
    }
    
    // MARK: Private (methods)
    
    /// If the current transcript value contains the the `App.actionPhrase` then
    /// the `textPublisher` instance will send it to any subscribers and the
    /// `SpeechPipeline` is stopped.
    private func parse() -> Void {

        if self.transcript.contains(App.actionPhrase.lowercased()) {

            self.textPublisher.send(self.transcript)
            self.stop()
        }
    }
    
    /// Sets the current `AVAudioSession` category to `.playAndRecord` and makes
    /// it active. Plays the item and will listen for the item to end.
    /// - Parameter playerItem: `AVPlayerItem` to play
    private func playOrQueueIfNecessary(_ playerItem: AVPlayerItem) -> Void {

        /// Set the appropriate audio session or bad things happen
        
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        self.player = AVPlayer(playerItem: playerItem)
        self.player.play()
        self.listenToNotification(playerItem)
    }
    
    /// Sets up `NSNotification.Name.AVPlayerItemDidPlayToEndTime` publisher
    /// to receive the player item that has finished playing and send it out to any subscribers
    /// - Parameter playerItem: `AVPlayerItem` that should be observed
    private func listenToNotification(_ playerItem: AVPlayerItem) -> Void {
        
        let _ = NotificationCenter.default
            .publisher(for: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            .map({ $0.object as! AVPlayerItem })
            .sink(
                receiveCompletion: {_ in },
                receiveValue: { value in
                    
                    print("what is my value \(String(describing: value))")

                    self.itemFinishedPublisher.send(value)
                }
            )
            .store(in: &self.subscriptions)
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
