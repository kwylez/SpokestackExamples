//
//  FeedCardViewDivider.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/23/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI

struct FeedCardViewDivider: View {
    
    // MARK: Internal (properties)
    
    var body: some View {
    
        Rectangle()
        .fill(Color.black)
        .opacity(0.10)
        .frame(height: 1)
        .padding(.horizontal, 25.0)
    }
}

struct FeedCardViewDivider_Previews: PreviewProvider {
    static var previews: some View {
        FeedCardViewDivider()
    }
}
