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

extension URL: Identifiable {
    
    public var id: String {
        return UUID().uuidString
    }
}

struct ContentView: View {
    
    // MARK: Internal (properties)
    
    @ObservedObject var viewModel: RSSViewModel = RSSViewModel()
    
    @State var feedItemURL: URL? = nil
    
    @State var currentItem: RSSFeedItem? = nil
    
    @State private var showModal: Bool = false
    
    var body: some View {
    
        NavigationView {
            
            ZStack {
                List {
                    Section(footer: FeedFooterView()) {
                        ForEach(self.viewModel.feedItems, id: \.publishedDate) { item in
                            
                            FeedCardView(feedItem: item, tellMoreCallback: {feedItem in
                                
                                self.viewModel.readArticleDescription(feedItem)

                            }, seeMoreCallback: {url in

                                self.feedItemURL = url
                                self.showModal = true

                            }, currentItem: self.$currentItem)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .onReceive(self.viewModel.$currentItem, perform: {newItem in
                    DispatchQueue.main.async {
                        
                        if self.viewModel.currentItem != nil {
                            self.currentItem = newItem
                        }
                    }
                })
                .onAppear{
                    self.viewModel.activateSpeech()
                }.onDisappear() {
                    self.viewModel.deactiveSpeech()
                }
                .sheet(isPresented: self.$showModal, content: {
                    SafariView(url: self.feedItemURL)
                })
                .navigationBarTitle("\(App.Feed.heading)", displayMode: .inline)
                
                VStack {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        WaveView()
                        FloatingActionButton()
                        .padding(.bottom, 40.0)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    
    // MARK: Initializers
    
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
