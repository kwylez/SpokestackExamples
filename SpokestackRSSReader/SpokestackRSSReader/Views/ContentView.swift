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
        
        VStack(alignment: .leading, spacing: 0.0) {
            
            ZStack {
    
                    Rectangle()
                        .foregroundColor(Color("Blue"))
                    Text("TechCrunch")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top, 30.0)

            }.frame(height: 125.0)
            Rectangle().foregroundColor(Color("Gray"))
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
