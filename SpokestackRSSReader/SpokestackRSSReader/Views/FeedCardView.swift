//
//  FeedCardView.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/23/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI

struct FeedCardView: View {
    
    var feedItem: RSSFeedItem
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Image("default-headline-image")
                Text("\(feedItem.title)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }.padding([.leading, .trailing], 10.0)
            FeedCardViewDivider()
            HStack {
                Spacer()
                Button(action: {}) {
                    Text("Tell me more").fontWeight(.bold)
                }
                Spacer()
                Button(action: {}) {
                    Text("See It").fontWeight(.bold)
                }
                Spacer()
            }.padding()
        }
    }
}

struct FeedCardView_Previews: PreviewProvider {
    static var previews: some View {
        FeedCardView(feedItem: RSSFeedItem(title: "VTEXT, an e-commerce platform used by Walmart, raises $140M led by SoftBank's LatAm fund", link: "https://spokestack.io/", description: "This is my position"))
    }
}
