//
//  RSSFeedTitleHeaderView.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 11/18/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI

let gradientStart = Color(red: 0.039, green: 0, blue: 0.21)
let gradientEnd = Color(red: 0.16, green: 0.22, blue: 0.52)

struct RSSFeedTitleHeaderView: View {
    
    var body: some View {
        
        ZStack {
        
            Rectangle()
            .fill(LinearGradient(
              gradient: .init(colors: [gradientStart, gradientEnd]),
              startPoint: .init(x: 0.5, y: 0),
              endPoint: .init(x: 0.5, y: 0.6)
            ))
            .cornerRadius(5)
            Text("TechCrunch")
            .foregroundColor(.white)
            .font(.title)
            .fontWeight(.semibold)
        }
    }
}

struct RSSFeedTitleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        RSSFeedTitleHeaderView()
    }
}
