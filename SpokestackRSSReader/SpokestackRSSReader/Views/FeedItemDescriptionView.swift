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
    
    @Binding var feedItemURL: URL?
    
    @Binding var showModal: Bool
    
    var body: some View {
        
        ZStack {
            VStack {
                
                ZStack {
                    Color("Blue")
                    Text("\"Tell me more\"")
                        .foregroundColor(.white)
                        .font(.headline).bold()
                        
                }
                .frame(height: 75)
                
                Text(currentItem?.description ?? "Description not available")
                    .font(.body)
                    .bold()
                    .padding(.horizontal)
                
                FeedCardViewDivider()
                
                HStack(alignment: .top) {
                    Spacer()
                    Button(action: {
                        self.showContent = false
                    }){
                      Text("\"Go back\"").font(.headline).bold()
                    }
                    .padding([.leading, .trailing], 20.0)
                    
                    Rectangle()
                    .fill(Color.black)
                    .opacity(0.10)
                    .frame(width: 1, height: 34.0)
                    .padding([.leading], 10.0)
                    
                    Spacer()
                    Button(action: {
                        
                        if let url: URL = URL(string: self.currentItem!.link) {
                         
                            self.feedItemURL = url
                            self.showModal = true
                        }
                    }){
                      Text("See it").font(.headline).bold()
                    }
                    .padding([.trailing], 10.0)
                    Spacer()
                }
                .padding()
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()

                    Image(systemName: "chevron.down.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(Color("Blue"))
                        .background(Color("LightBlue"))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .offset(x: -16, y: 16)
            .transition(.move(edge: .top))
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0))
            .onTapGesture {
                self.showContent = false
            }
        }
        .background(Color.white)
    }
}

struct FeedItemDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        FeedItemDescriptionView(showContent: .constant(false),
                                currentItem: .constant(nil),
                                feedItemURL: .constant(nil),
                                showModal: .constant(false))
    }
}
