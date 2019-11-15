//
//  Typealiases.swift
//  Spokestack
//
//  Created by Cory D. Wiles on 9/28/18.
//  Copyright © 2018 Pylon AI, Inc. All rights reserved.
//

import Foundation

public typealias SpeechRecognitionClosure<T> = (_ result: SPSpeechRecognitionResult<T, SPSpeechRecognitionError>) -> Void
