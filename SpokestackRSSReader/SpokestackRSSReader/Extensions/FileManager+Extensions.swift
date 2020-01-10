//
//  FileManager+Extensions.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 12/12/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation

extension FileManager {

    // MARK: Internal (properties)
    
    static var spk_documentsDir: URL? {
        return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor :nil, create: false)
    }
}
