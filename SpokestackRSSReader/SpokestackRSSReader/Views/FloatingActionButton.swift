//
//  FloatingActionButton.swift
//  SpokestackRSSReader
//
//  Created by Cory D. Wiles on 1/31/20.
//  Copyright © 2020 Spokestack. All rights reserved.
//

import SwiftUI

struct FloatingActionButton: View {
    
    var body: some View {
    
        ZStack {
            
//            Circle()
//                .fill(Color("Blue"))
//                .frame(width: 78.0, height: 78.0)
//                .shadow(color: Color("Blue").opacity(0.7), radius: 10.0)
//                .shadow(color: Color("Blue").opacity(0.5), radius: 10.0)
//
//            Image(systemName: "play.fill")
//                .foregroundColor(Color("AquaMarine"))
//                .font(.system(size: 45.0, weight: .thin))
//                .padding(.leading, 8)
            
            Circle()
                .fill(Color("LightBlue"))
                .frame(width: 78.0, height: 78.0)
                .shadow(color: Color("LightBlue").opacity(0.7), radius: 10.0)
                .shadow(color: Color("LightBlue").opacity(0.5), radius: 10.0)
            
            Image(systemName: "pause.fill")
                .foregroundColor(Color("Blue"))
                .font(.system(size: 45.0, weight: .thin))
        }
    }
}

struct FloatingActionButton_Previews: PreviewProvider {
    static var previews: some View {
        FloatingActionButton()
    }
}
