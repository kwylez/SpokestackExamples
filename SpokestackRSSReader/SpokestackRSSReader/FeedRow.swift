//
//  FeedRow.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/15/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import Foundation
import SwiftUI

struct FeedRow: View {

    var feed: Feed

    var body: some View {
        Text("Come and eat at \(feed.description)")
    }
}
