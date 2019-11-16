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

let items: Array<Feed> = [
    Feed(title: "Hello World",
             link: "http://www.yahoo.com/",
             description: "First Descriptions", items: []),
    Feed(title: "Hello World 2",
             link: "http://www.google.com/",
             description: "First Descriptions 2", items: [])
]

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    FeedRow(feed: item)
                }
            }
            .navigationBarTitle("TechCrunch")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
