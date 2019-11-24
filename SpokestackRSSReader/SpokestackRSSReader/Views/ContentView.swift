//
//  ContentView.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/14/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI
import Spokestack
import FeedKit
import Combine

fileprivate let BackgroundColor: UIColor = UIColor(red: 246/255, green: 249/255, blue: 252/255, alpha: 1.0)

struct ContentView: View {
    
    @ObservedObject var viewModel: RSSViewModel = RSSViewModel()
    
    let items = [
        RSSFeedItem(title: "VTEXT, an e-commerce platform used by Walmart, raises $140M led by SoftBank's LatAm fund", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello1", link: "link1", description: "my description1"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello1", link: "link1", description: "my description1"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "Hello", link: "link", description: "my description"),
        RSSFeedItem(title: "VTEXT, an e-commerce platform used by Walmart, raises $140M led by SoftBank's LatAm fund", link: "link", description: "my description"),
    ]
    
    var body: some View {
    
        GeometryReader { reader in
        
            VStack(alignment: .leading, spacing: 0.0) {
                
                ZStack {
        
                    Rectangle()
                        .foregroundColor(Color("Blue"))
                    Text("TechCrunch")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top, 30.0)

                }
                .frame(height: 125.0)
                List (self.viewModel.feedItems, id: \.title){item in
                    FeedCardView(feedItem: item)
                }
                .onAppear{
                    
                    UITableView.appearance().separatorStyle = .none
                    UITableView.appearance().backgroundColor = BackgroundColor
                    UITableViewCell.appearance().backgroundColor = BackgroundColor
                    
                    self.viewModel.activatePipeline()

                }.onDisappear() {
                    self.viewModel.deactivePipeline()
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
