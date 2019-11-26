//
//  FeedCardViewDivider.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/23/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI

struct FeedCardViewDivider: View {
    var body: some View {
        Rectangle()
        .fill(Color("Gray"))
        .frame(height: 1)
    }
}

struct FeedCardViewDivider_Previews: PreviewProvider {
    static var previews: some View {
        FeedCardViewDivider()
    }
}
