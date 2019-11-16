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

let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)

struct ContentView: View {
    
    @ObservedObject var viewModel: RSSViewModel = RSSViewModel()
    
    var body: some View {
        
        NavigationView {
            GeometryReader{ geometry in
                VStack {
                
                    Rectangle()
                    .fill(LinearGradient(
                      gradient: .init(colors: [gradientStart, gradientEnd]),
                      startPoint: .init(x: 0.5, y: 0),
                      endPoint: .init(x: 0.5, y: 0.6)
                    ))
                    .cornerRadius(5)
                    .frame(width: geometry.size.width * 0.95, height: 120.0)
                    
                    List {
                        ForEach(self.viewModel.feedItems) { item in
                            FeedItemRow(feedItem: item)
                        }
                    }
                }
                .onAppear{
                    self.viewModel.load()
                }
                .navigationBarTitle("Spokestack RSS Reader")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
