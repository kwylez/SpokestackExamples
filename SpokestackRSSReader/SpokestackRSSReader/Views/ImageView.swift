//
//  ImageView.swift
//  SpokestackRSSReader
//
//  Created by Cory Wiles on 12/6/19.
//  Copyright © 2019 Spokestack. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    
    // MARK: Internal (properties)
    
    @ObservedObject var imageLoader: RemoteImageController = RemoteImageController()
    
    @State var image: Image = Image("default-headline-image")
    
    var imageURL: String
    
    var body: some View {
    
        VStack {
        
            self.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 72, height: 73)

        }.onReceive(self.imageLoader.$isValidImage, perform: {newValue in

            if newValue {
                self.image = Image(uiImage: self.imageLoader.image)
            }

        }).onAppear(perform: {
            self.imageLoader.fetch(self.imageURL)
        })
    }
    
    // MARK: Initializers
    
    init(_ url: String) {
        self.imageURL = url
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView("")
    }
}
