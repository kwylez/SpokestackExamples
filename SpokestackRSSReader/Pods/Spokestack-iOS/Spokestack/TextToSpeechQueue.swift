//
//  TextToSpeechQueue.swift
//  Spokestack
//
//  Created by Cory Wiles on 12/15/19.
//  Copyright © 2019 Pylon AI, Inc. All rights reserved.
//

import Foundation
import Combine

private let TTSSpeechQueueName: String = "com.spokestack.ttsspeech.queue"

private let apiQueue = DispatchQueue(label: TTSSpeechQueueName, qos: .userInitiated, attributes: .concurrent)

public struct TTSQueueURL: Codable {
    
    public let url: String
}

@available(iOS 13.0, *)
@objc public class TextToSpeechQueue: NSObject {
    
    // MARK: Properties
    
    private var configuration: SpeechConfiguration
    
    private let decoder = JSONDecoder()
    
    // MARK: Initializers
    
    @objc public init(_ configuration: SpeechConfiguration) {
        self.configuration = configuration
        super.init()
    }
    
    @objc public override init() {
        self.configuration = SpeechConfiguration()
        super.init()
    }
    
    // MARK: Public methods
    
    public func synthesize(_ inputs: Array<TextToSpeechInput>) -> AnyPublisher<[URL], Error> {

        return self.mergedInputs(inputs).scan([]) { inputs, input -> [URL] in
            return inputs + [input]
        }
        .eraseToAnyPublisher()
    }
    
    public func synthesize(_ input: TextToSpeechInput) -> AnyPublisher<URL, Error> {
        var request = URLRequest(url: URL(string: "https://core.pylon.com/speech/v1/tts/synthesize")!)
        request.addValue(self.configuration.authorization, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let body = ["voice": input.voice,
                    "text": input.input]
        request.httpBody =  try? JSONSerialization.data(withJSONObject: body, options: [])
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
              print("Network request will start")
            }, receiveOutput: { output in
                print("Network request data received \(output.response)")
            }, receiveCancel: {
              print("Network request cancelled")
            })
            .receive(on: apiQueue)
            .map(\.data)
            .decode(type: TTSQueueURL.self, decoder: decoder)
            .map{ URL(string: $0.url)! }
            .catch{ _ in Empty<URL, Error>() }
            .eraseToAnyPublisher()
    }
    
    // MARK: Private methods)
    
    private func mergedInputs(_ inputs: Array<TextToSpeechInput>) -> AnyPublisher<URL, Error> {
        
        precondition(!inputs.isEmpty)
        
        let initialPublisher = self.synthesize(inputs[0])
        let remainder = Array(inputs.dropFirst())
        
        return remainder.reduce(initialPublisher) { combined, ttsInput in
            return combined
                .merge(with: synthesize(ttsInput))
                .eraseToAnyPublisher()
        }
    }
}

