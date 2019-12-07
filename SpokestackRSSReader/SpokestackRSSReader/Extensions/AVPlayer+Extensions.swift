//
//  AVPlayer+Extensions.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 12/7/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer {

    // MARK: Internal (properties)
    
    var spk_isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
