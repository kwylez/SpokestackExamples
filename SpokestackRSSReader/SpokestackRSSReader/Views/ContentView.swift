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
fileprivate let NavigationBarBackgroundColor: UIColor = UIColor(red: 47/255, green: 91/255, blue: 234/255, alpha: 1.0)

struct ContentView: View {
    
    @ObservedObject var viewModel: RSSViewModel = RSSViewModel()
    
    var body: some View {
    
        NavigationView {
            
            List (self.viewModel.feedItems, id: \.title){item in
                FeedCardView(feedItem: item)
            }
            .onAppear{
                self.viewModel.activatePipeline()
            }.onDisappear() {
                self.viewModel.deactivePipeline()
            }
            .navigationBarTitle("TechCrunch", displayMode: .inline)
        }
    }
    
    init() {
        
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = BackgroundColor
        UITableViewCell.appearance().backgroundColor = BackgroundColor
                
        UINavigationBar.appearance().backgroundColor = NavigationBarBackgroundColor
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = NavigationBarBackgroundColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
