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

struct ContentView: View {
    
    @ObservedObject var viewModel: RSSViewModel = RSSViewModel()
    
    var body: some View {
        
        NavigationView {

            VStack(alignment: .center, spacing: 0.0) {
                RSSFeedTitleHeaderView().frame(width: UIScreen.main.bounds.size.width * 0.95, height: 120.0)
                List {
                    ForEach(self.viewModel.feedItems) { item in
                        FeedItemRow(feedItem: item)
                    }
                }
                Spacer()
            }
            .onAppear{
                self.viewModel.activatePipeline()
            }.onDisappear() {
                self.viewModel.deactivePipeline()
            }
            .navigationBarTitle(App.title)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
