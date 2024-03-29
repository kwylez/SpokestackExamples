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
    
    @State var showContent: Bool = false
    
    @State var feedItemURL: URL? = nil
    
    @State var showModal: Bool = false

    // MARK: Private (properties)
    
    @EnvironmentObject var viewModel: RSSViewModel
    
    var body: some View {
    
        NavigationView {
            
            ZStack {
                List {
                    Section(footer: FeedFooterView()) {
                        ForEach(self.viewModel.feedItems, id: \.publishedDate) { item in
                            
                            FeedCardView(feedItem: item, tellMoreCallback: {feedItem in
                                
                                self.viewModel.readArticleDescription(feedItem)
                                self.showContent = true

                            }, seeMoreCallback: {url in

                                self.feedItemURL = url
                                self.showModal = true
                            })
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .onAppear{
                    self.viewModel.activateSpeech()
                }.onDisappear() {
                    self.viewModel.deactiveSpeech()
                }
                .sheet(isPresented: self.$showModal, content: {
                    SafariView(url: self.feedItemURL)
                })
                .navigationBarTitle(self.showContent ? "" : "\(App.Feed.heading)", displayMode: .inline)
                .navigationBarHidden(self.showContent)
                .blur(radius: showContent ? 5 : 0)
                
                VStack {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        WaveView()
                            .opacity(self.viewModel.actionButtonStatus == .isListening ? 1 : 0)
                        FloatingActionButton()
                        .padding(.bottom, 40.0)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                
                if self.showContent {
                    
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.8)
                        .onTapGesture {
                            self.showContent.toggle()
                    }
                    
                    /// Note:
                    /// You have to set the zIndex to 1 or the the "dismissal" will not animate properly
                    
                    FeedItemDescriptionView(showContent: $showContent,
                                            feedItemURL: $feedItemURL,
                                            showModal: $showModal)
                        .environmentObject(self.viewModel)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0))
                        .offset(x: 0, y: 100.0)
                        .zIndex(1)
                }
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
