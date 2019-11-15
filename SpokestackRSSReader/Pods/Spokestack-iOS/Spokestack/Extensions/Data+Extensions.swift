//
//  Data+Extensions.swift
//  Spokestack
//
//  Created by Cory D. Wiles on 12/26/18.
//  Copyright © 2018 Pylon AI, Inc. All rights reserved.
//

import Foundation

extension Data {
    
    // MARK: Internal (methods)
    
    func elements<T>() -> [T] {
        return withUnsafeBytes {
            Array(UnsafeBufferPointer<T>(start: $0, count: count/MemoryLayout<T>.size))
        }
    }
}
