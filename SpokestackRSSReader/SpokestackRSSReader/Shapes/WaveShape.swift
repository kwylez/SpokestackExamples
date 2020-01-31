//
//  WaveShape.swift
//  SpokestackRSSReader
//
//  Created by Cory D. Wiles on 1/30/20.
//  Copyright © 2020 Spokestack. All rights reserved.
//

import SwiftUI

struct WaveShape: Shape {
    
    let graphWidth: CGFloat
    
    let amplitude: CGFloat
    
    func path(in rect: CGRect) -> Path {
            
        let width = rect.width
        let height = rect.height

        let origin = CGPoint(x: 0, y: height * 0.50)

        var path = Path()
        path.move(to: origin)

        var endY: CGFloat = 0.0
        let step = 5.0

        for angle in stride(from: step, through: Double(width) * (step * step), by: step) {

            let x = origin.x + CGFloat(angle/360.0) * width * graphWidth
            let y = origin.y - CGFloat(sin(angle/180.0 * Double.pi)) * height * amplitude

            path.addLine(to: CGPoint(x: x, y: y))
            endY = y
        }
        path.addLine(to: CGPoint(x: width, y: endY))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: origin.y))

        return path
    }
}

struct WaveShape_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
                WaveShape(graphWidth: 1, amplitude: 0.05)
                    .fill(Color.red)
                    .opacity(0.3)
                WaveShape(graphWidth: 0.5, amplitude: 0.02)
                    .fill(Color.blue)
                    .opacity(0.3)
                WaveShape(graphWidth: 0.8, amplitude: 0.04)
                    .fill(Color.green)
                    .opacity(0.3)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
