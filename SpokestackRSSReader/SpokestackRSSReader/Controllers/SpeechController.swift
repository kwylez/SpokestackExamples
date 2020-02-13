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

enum SpeechControllerErrors: Error {
    case failedToCache
    case invalidRemoteURL
}

typealias PlayerItemTimeValue = (item: AVPlayerItem, elapsedTime: Double, itemDuration: Double)

/// Controller class for controlling an RSS feed
final class SpeechController: NSObject {
    
    // MARK: Internal (properties)
    
    /// Subject that publishes the transcriped text to any subscribers
    let textPublisher = PassthroughSubject<String, Never>()
    
    /// Subject that publishes the `AVPlayerItem` that finished playing to any subscribers
    let itemFinishedPublisher = PassthroughSubject<AVPlayerItem, Never>()
    
    /// Subject that publishes when a feed item has been sythesized and cached
    let synthesizeFeedItemHasFinished = PassthroughSubject<RSSFeedItem, Never>()
    
    /// Subject that publishes when a synthesized item is finished and sends the remote URL
    let synthesizeHasFinished = PassthroughSubject<URL, Never>()

    /// Pause state of the player
    private (set) var isPaused: Bool = false
    
    /// Returns if the player is playing or not
    var isPlaying: Bool {
        return self.player.spk_isPlaying
    }
    
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
    
    /// The `RSSFeedItemTTSType` enum
    private var itemTTSType: RSSFeedItemTTSType?
    
    /// The current `RSSFeedItem` instance that is being processed
    private var feedItem: RSSFeedItem?
    
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
    
    /// Sets pipeline and avSpeechSynthesizer  delegate to nil
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
    /// - Returns: Void
    func respond(_ text: String) -> Void {

        let input = TextToSpeechInput(text)
        
        self.tts?.synthesize([input])
        .tryMap {results -> URL in
            guard let result: TextToSpeechResult = results.first,
                let url: URL = result.url else {
                
                    throw SpeechControllerErrors.invalidRemoteURL
            }
            
            return url
        }
        .sink(receiveCompletion: {_ in }, receiveValue: {resultURL in
            self.synthesizeHasFinished.send(resultURL)
        })
        .store(in: &self.subscriptions)
    }
    
    /// Plays `AVPlayerItem` instance for the given url
    /// - Parameter url: `URL` of sound file
    /// - Returns: Void
    func play(_ url: URL) -> Void {
        
        let playerItem = AVPlayerItem(url: url)
        self.playItem(playerItem)
    }
    
    func pause() -> Void {
        
        self.player.pause()
        self.isPaused.toggle()
    }
    
    func resumePlayback() -> Void {
        
        self.player.play()
        self.isPaused.toggle()
    }
    
    /// Synthesizes and caches audio locally
    /// - Parameter items: `Array<RSSFeedItem>`
    /// - Returns: `AnyPublisher<[URL], Error>`
    func processFeedItemsDescriptionsPublisher(_ items: Array<RSSFeedItem>) -> AnyPublisher<[URL], Error> {
        
        precondition(self.tts != nil, "TextToSpeech instance can't be nil")
        
        let headlineInputs: Array<TextToSpeechInput> = items.map{ TextToSpeechInput($0.description) }
        let headlinesPublisher = self.tts!.synthesize(headlineInputs)

        return headlinesPublisher
            .tryMap{results -> [URL] in
                return results.compactMap{$0.url}
            }
            .flatMap{urls in
                return Publishers.MergeMany(
                    urls.map(self.processAudioURL)
                )
                .collect()
            }
            .eraseToAnyPublisher()
    }

    
    // MARK: Private (methods)
    
    /// If the current transcript value contains the the `App.actionPhrase` then
    /// the `textPublisher` instance will send it to any subscribers and the
    /// `SpeechPipeline` is stopped.
    /// - Returns: Void
    private func parse() -> Void {

        if self.transcript.contains(App.actionPhrase.lowercased()) {

            self.textPublisher.send(self.transcript)
            self.stop()
        }
    }
    
    /// Sets the current `AVAudioSession` category to `.playAndRecord` and makes
    /// it active. Plays the item and will listen for the item to end.
    /// - Parameter playerItem: `AVPlayerItem` to play
    /// - Returns: Void
    private func playItem(_ playerItem: AVPlayerItem) -> Void {

        /// Set the appropriate audio session or bad things happen
        
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                         options: [
                                                            .allowAirPlay,
                                                            .allowBluetooth,
                                                            .allowBluetoothA2DP,
                                                            .defaultToSpeaker
                                                         ]
        )

        try? AVAudioSession.sharedInstance().setActive(true)

        self.player.replaceCurrentItem(with: playerItem)
        self.player.play()
        self.listenToNotification(playerItem)
    }
    
    /// Sets up `NSNotification.Name.AVPlayerItemDidPlayToEndTime` publisher
    /// to receive the player item that has finished playing and send it out to any subscribers
    /// - Parameter playerItem: `AVPlayerItem` that should be observed
    /// - Returns: Void
    private func listenToNotification(_ playerItem: AVPlayerItem) -> Void {
        
        let _ = NotificationCenter.default
            .publisher(for: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            .map{ $0.object as! AVPlayerItem }
            .sink(
                receiveCompletion: {_ in },
                receiveValue: { value in
                    self.itemFinishedPublisher.send(value)
                }
            )
            .store(in: &self.subscriptions)
    }
    
    
    /// Fetches the remote sound file and save it locally
    /// - Parameter url: Remote `URL` of file
    /// - Returns: `AnyPublisher<URL, Error>`
    private func processAudioURL(_ url: URL) -> AnyPublisher<URL, Error> {
        return self.fetchSoundFile(url)
        .tryMap{data -> URL in
            return try self.processMP3(data)
        }
        .eraseToAnyPublisher()
    }
    
    /// Fetches the remote sounds file
    /// - Parameter remoteURL: `URL` of file
    /// - Returns: `AnyPublisher<Data, Error>`
    private func fetchSoundFile(_ remoteURL: URL) -> AnyPublisher<Data, Error> {

        return URLSession.shared.dataTaskPublisher(for: remoteURL)
        .mapError { $0 as Error }
        .map { $0.data }
        .eraseToAnyPublisher()
    }
    
    /// Saves the audio data locally to an mp3
    /// - Parameter data: Audio `Data`
    /// - Returns: `URL`
    /// - Throws: `SpeechControllerErrors.failedToCache`
    private func processMP3(_ data: Data) throws -> URL {
        
        let filename: String = UUID().uuidString + ".mp3"
        let documentDirectory: URL = FileManager.spk_documentsDir!
        let fileURL: URL = documentDirectory.appendingPathComponent(filename)

        do {
            
            try data.write(to: fileURL)
            
        } catch {
            
            throw SpeechControllerErrors.failedToCache
        }
        
        return fileURL
    }
}

extension SpeechController: SpeechEventListener {
    
    /// `SpeechPipeline` as been activated
    func activate() {
        print("did activate")
    }
    
    /// `SpeechPipeline` as been de-activated. Sets the `transcript` to empty string
    func deactivate() {
        print("did deactivate \(self.transcript)")
        self.transcript = ""
    }
    
    /// `SpeechPipeline` has encountered an error
    /// - Parameter error: `Error`
    func didError(_ error: Error) {
        print("did didError \(error)")
    }
    
    /// `SpeechPipeline` has received a trace value
    /// - Parameter trace: `String` trace value
    func didTrace(_ trace: String) {
        print("did trace \(trace)")
    }
    
    /// `SpeechPipeline` has been stopped
    func didStop() {
        print("didStop")
    }
    
    /// `SpeechPipeline` has been started
    func didStart() {
        print("didStart")
    }
    
    /// `SpeechPipeline` did recognize speech. The `transcript` value is set and `parse` is called.
    /// - Parameter result: `SpeechContext`
    func didRecognize(_ result: SpeechContext) {
        
        print("didRecognize \(result.isSpeech) and transscript \(result.transcript)")
        self.transcript = result.transcript
        self.parse()
    }
    
    /// The `SpeechPipeline` ASR or Wakeword has timedout
    func didTimeout() {
        print("didTimeout")
    }
}

extension SpeechController: PipelineDelegate {
    
    /// The `PipelineDelegate ` has been initiated
    func didInit() {
        print("didInit")
    }
    
    /// Setting up the `PipelineDelegate` has failed
    /// - Parameter error: `String` error description
    func setupFailed(_ error: String) {
        print("error \(error)")
    }
}

extension SpeechController: TextToSpeechDelegate {
    
    func success(result: TextToSpeechResult) {
        print("result \(result)")
    }
    
    func didBeginSpeaking() {
        print("didBeginSpeaking")
    }
    
    func didFinishSpeaking() {
        print("didFinishSpeaking")
    }
    
    func failure(error: Error) {
        print(error)
    }
}
