//
//  FeedItemDescriptionView.swift
//  SpokestackRSSReader
//
//  Created by Cory D. Wiles on 2/6/20.
//  Copyright © 2020 Spokestack. All rights reserved.
//

import SwiftUI

struct FeedItemDescriptionView: View {
    
    @Binding var showContent: Bool
    
    @Binding var currentItem: RSSFeedItem?
    
    var body: some View {
        
        ZStack {

            Color("Blue")
            Text(currentItem?.description ?? "No description")
            
            VStack {
                HStack {
                    Spacer()

                    Image(systemName: "chevron.down.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .offset(x: -16, y: 16)
//            .transition(.move(edge: .top))
//            .animation(.spring())
//            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0))
            .onTapGesture {
                self.showContent = false
            }
        }
    }
}

struct FeedItemDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        FeedItemDescriptionView(showContent: .constant(false), currentItem: .constant(nil))
    }
}
