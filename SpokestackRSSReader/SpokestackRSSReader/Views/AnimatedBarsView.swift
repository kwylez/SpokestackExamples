//
//  AnimatedBarsView.swift
//  SpokestackRSSReader
//
//  Created by Cory D. Wiles on 2/5/20.
//  Copyright © 2020 Spokestack. All rights reserved.
//

import SwiftUI

struct AnimatedBarsView: View {
    
    var height: CGFloat
    
//    @State var change: Bool = false
    
    @Binding var currentItem: RSSFeedItem?
    
    @Binding var feedItem: RSSFeedItem
    
    private var isCurrent: Bool {
        
        guard let current: RSSFeedItem = self.currentItem else {
            return false
        }
        
        return current.title == feedItem.title
    }
    
    var body: some View {
            
        HStack(alignment: .bottom, spacing: 2.0) {
            
            Rectangle()
                .fill(Color.red)
                .foregroundColor(.white)
                .frame(width: 2.5, height: 10)
                .scaleEffect(x: 1, y: isCurrent ? 1.5 : 1, anchor: .bottom)
                .animation(Animation.linear(duration: 0.6).repeatForever())
            
            Rectangle()
                .fill(Color.red)
                .foregroundColor(.white)
                .frame(width: 2.5, height: 10)
                .scaleEffect(x: 1, y: isCurrent ? 1.5 : 1, anchor: .bottom)
                .animation(Animation.linear(duration: 0.3).repeatForever())

            Rectangle()
                .fill(Color.red)
                .foregroundColor(.white)
                .frame(width: 2.5, height: 10)
                .scaleEffect(x: 1, y: isCurrent ? 1.5 : 1, anchor: .bottom)
                .animation(Animation.linear(duration: 0.4).repeatForever())

            Rectangle()
                .fill(Color.red)
                .foregroundColor(.white)
                .frame(width: 2.5, height: 10)
                .scaleEffect(x: 1, y: isCurrent ? 1.5 : 1, anchor: .bottom)
                .animation(Animation.linear(duration: 0.2).repeatForever())
        }
        .opacity(isCurrent ? 1 : 0).animation(.default)
    }
}

struct AnimatedBarsView_Previews: PreviewProvider {
    
    static var previews: some View {
    
        AnimatedBarsView(height: 50.0,
                         currentItem: .constant(nil),
                         feedItem: .constant(RSSFeedItem(publishedDate: Date(),
                                                         title: "Test",
                                                         link: "link",
                                                         description: "description",
                                                         imageLink: "imageLink",
                                                         cachedHeadlineLink: nil,
                                                         cachedDescriptionLink: nil)))
    }
}
