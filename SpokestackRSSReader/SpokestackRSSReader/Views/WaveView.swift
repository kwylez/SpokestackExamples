//
//  WaveView.swift
//  SpokestackRSSReader
//
//  Created by Cory D. Wiles on 1/30/20.
//  Copyright © 2020 Spokestack. All rights reserved.
//

import SwiftUI

struct WaveView: View {

    var body: some View {
    
        ZStack {
            Spacer()
            WaveShape(graphWidth: 0.8, amplitude: 0.05)
                .fill(Color("Blue"))
                .opacity(0.10)

            WaveShape(graphWidth: 0.5, amplitude: 0.02)
                .fill(Color("Blue"))
                .opacity(0.25)
        }
    }
}

struct WaveView_Previews: PreviewProvider {
    static var previews: some View {
        WaveView()
    }
}
