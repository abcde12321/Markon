//
//  SwiftUIView.swift
//  MarkonExtension
//
//  Created by Fan Yang on 19/08/2024.
//

import SwiftUI

//struct CustomEffect: Identifiable {
//    let id = UUID()
//    let name: String
//    var sliders: [SliderInfo]
//    let applyEffect: (NSImage, [Double]) async -> NSImage?
//}

enum ImageProcessingState {
    case loading
    case processed(PlatformImage)
    case error
}

// ProcessedImageView with asynchronous image loading
struct ProcessedImageView: View {

    let effectImage: EffectImage
    let isSelected: Bool
    
    var body: some View {
           VStack {
               Text(effectImage.effect.name)
               
               if let image = effectImage.image{
                   Image(platformImage: image)
                       .resizable()
                       .aspectRatio(contentMode: .fit)
               }else{
                   loadingView
               }
           }
           .background(
               RoundedRectangle(cornerRadius: 0)
                   .stroke(isSelected ? Color.green : Color.clear, lineWidth: 4)
           )
       }

    
    var loadingView: some View{
        ProgressView("Processing...")
            //.frame(width: width, height: height)
    }
    
    var errorView: some View{ // Show when process error
        Image(systemName: "exclamationmark.triangle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.red)
    }
       
}


//#Preview {
//    SwiftUIView()
//}
