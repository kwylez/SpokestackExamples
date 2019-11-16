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
            List {
                ForEach(viewModel.feedItems) { item in
                    FeedItemRow(feedItem: item)
                }
            }
            .onAppear{
                self.viewModel.load()
            }
            .navigationBarTitle("Spokestack RSS Reader")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
