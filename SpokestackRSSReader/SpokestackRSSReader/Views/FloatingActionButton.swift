//
//  FloatingActionButton.swift
//  SpokestackRSSReader
//
//  Created by Cory D. Wiles on 1/31/20.
//  Copyright © 2020 Spokestack. All rights reserved.
//

import SwiftUI

enum FloatingActionButtonStatus {
    case isPlaying, isPaused, isListening, isWaiting, isFinished, unknown
}

struct FloatingActionButton: View {
    
    @EnvironmentObject var viewModel: RSSViewModel
    
    var shouldAnimateListening: Bool {
        return self.viewModel.actionButtonStatus == .isListening
    }
    
    var body: some View {
        
        return ZStack {

            /// Play
            
            Circle()
                .fill(Color("Blue"))
                .shadow(color: Color("Blue").opacity(0.7), radius: 10.0)
                .shadow(color: Color("Blue").opacity(0.5), radius: 10.0)
                .opacity(viewModel.actionButtonStatus == .isPaused ? 1 : 0)
                .animation(.default)

            Image(systemName: "play.fill")
                .foregroundColor(Color("AquaMarine"))
                .font(.system(size: 45.0, weight: .thin))
                .padding(.leading, 8)
                .opacity(viewModel.actionButtonStatus == .isPaused ? 1 : 0)
                .animation(.default)
                .onTapGesture {
                    
                    self.viewModel.actionButtonStatus = .isPlaying
                    self.viewModel.resumePlayback()
                }

            /// Pause

            Circle()
                .fill(Color("LightBlue"))
                .frame(width: 78.0, height: 78.0)
                .shadow(color: Color("LightBlue").opacity(0.7), radius: 10.0)
                .shadow(color: Color("LightBlue").opacity(0.5), radius: 10.0)
                .opacity(viewModel.actionButtonStatus == .isPlaying ? 1 : 0)
                .animation(.default)

            Image(systemName: "pause.fill")
                .foregroundColor(Color("Blue"))
                .font(.system(size: 45.0, weight: .thin))
                .opacity(viewModel.actionButtonStatus == .isPlaying ? 1 : 0)
                .animation(.default)
                .onTapGesture {
                    
                    self.viewModel.actionButtonStatus = .isPaused
                    self.viewModel.pausePlayback()
                }
            
            /// Listening
            
            Circle()
                .fill(Color("LightBlue"))
                .shadow(color: Color("LightBlue").opacity(0.7), radius: 10.0)
                .shadow(color: Color("LightBlue").opacity(0.5), radius: 10.0)
                .opacity(viewModel.actionButtonStatus == .isListening ? 1 : 0)
                .animation(.default)

            HStack {

                ForEach(0...2, id: \.self) { index in

                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color("Blue"))
                        .scaleEffect(self.shouldAnimateListening ? 1.2 : 0)
                        .animation(Animation.linear(duration: 0.6).repeatForever().delay(0.25 * Double(index)))
                }
            }
            .opacity(viewModel.actionButtonStatus == .isListening ? 1 : 0)
            .animation(.default)
        }
        .frame(width: 78.0, height: 78.0)
    }
}

struct FloatingActionButton_Previews: PreviewProvider {

    static var previews: some View {
        FloatingActionButton()
    }
}
