//
//  FeedCardView.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/23/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI

typealias FeedCardTellMoreCallback = (_ feedItem: RSSFeedItem) -> Void
typealias FeedCardSeeMoreCallback = (_ url: URL) -> Void

struct ImageView: View {
    
    // MARK: Internal (properties)
    
    @ObservedObject var imageLoader: RemoteImageController = RemoteImageController()
    
    @State var image: Image = Image("default-headline-image")
    
    var imageURL: String
    
    var body: some View {
    
        VStack {
        
            self.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 72, height: 73)

        }.onReceive(self.imageLoader.$isValidImage, perform: {newValue in

            print("image loader is valid \(self.imageLoader.isValidImage) newValue \(newValue)")
            
            if self.imageLoader.isValidImage {
                self.image = Image(uiImage: self.imageLoader.image)
            }
        }).onAppear(perform: {
            self.imageLoader.fetch(self.imageURL)
        })
    }
    
    // MARK: Initializers
    
    init(_ url: String) {
        self.imageURL = url
    }
}

struct FeedCardView: View {
    
    // MARK: Internal (properties)
    
    var feedItem: RSSFeedItem
    
    var tellMoreCallback: FeedCardTellMoreCallback?
    
    var seeMoreCallback: FeedCardSeeMoreCallback?
    
    @Binding var currentItem: RSSFeedItem?
    
    var body: some View {

        VStack {
            HStack(alignment: .top) {
                ImageView(self.feedItem.imageLink)
                    .padding([.leading, .trailing], 10.0)
                Text("\(self.feedItem.title)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                Spacer()
            }
            .padding([.leading, .trailing, .top], 10.0)
            FeedCardViewDivider()
            HStack {
                Text("\"Tell me more\"")
                .fontWeight(.bold)
                .foregroundColor(Color("Blue"))
                .padding([.leading, .trailing], 20.0)
                .onTapGesture {
                    self.tellMoreCallback?(self.feedItem)
                }
                Rectangle()
                .fill(Color("Gray"))
                .frame(width: 1)
                .padding([.leading, .trailing], 10.0)
                Spacer()
                Text("See It")
                .fontWeight(.bold)
                .foregroundColor(Color("Blue"))
                .padding([.leading, .trailing], 10.0)
                .onTapGesture {

                    if let url: URL = URL(string: self.feedItem.link) {
                        self.seeMoreCallback?(url)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
            .stroke(Color("AquaMarine"), lineWidth: isCurrent ? 4 : 0)
        )
        .cornerRadius(10.0)
        .shadow(color: Color.gray.opacity(0.4), radius: 5.0)
        .scaleEffect(isCurrent ? 1.05 : 1)
        .animation(.easeInOut(duration: 0.3))
    }
    
    // MARK: Private (properties)
    
    private var isCurrent: Bool {
        
        guard let current: RSSFeedItem = self.currentItem else {
            return false
        }
        
        return current.title == feedItem.title
    }
}

//struct FeedCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedCardView(feedItem: RSSFeedItem(title: "VTEXT, an e-commerce platform used by Walmart, raises $140M led by SoftBank's LatAm fund", link: "https://spokestack.io/", description: "This is my position"), currentItem: RSSFeedItem(title: "VTEXT, an e-commerce platform used by Walmart, raises $140M led by SoftBank's LatAm fund", link: "https://spokestack.io/", description: "This is my position"))
//    }
//}
