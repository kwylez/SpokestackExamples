//
//  FeedFooterView.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 12/6/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI

struct FeedFooterView: View {
    
    // MARK: Internal (properties)
    
    var body: some View {
        HStack {
            Spacer()
            Text("You're all caught up")
            .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

struct FeedFooterView_Previews: PreviewProvider {
    static var previews: some View {
        FeedFooterView()
    }
}
