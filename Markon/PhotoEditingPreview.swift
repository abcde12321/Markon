//
//  PhotoEditingPreview.swift
//  MarkonExtension
//
//  Created by Fan Yang on 08/08/2024.
//

import SwiftUI

struct PhotoEditingPreview: View {
    
    @StateObject var imageProcessor = CIFilterProcessor.shared
    
    var body: some View {
        VStack {
            HStack{
                if let originalImage = imageProcessor.originalImage{
                    VStack {
                        Image(platformImage: originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 4)
                            )
                        Text("Original Image")
                    }
                    .padding()
                }
                
                if let effect = imageProcessor.selectedEffect {
                    // Processed Image
                    VStack {
                        if let image = imageProcessor.processedImage{
                            Image(platformImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 4)
                                )
                        }
                        Text("Processed Image")
                    }
                    .padding()
                    
                    // Sliders for selected effect
                    VStack {
                        ForEach(effect.sliders.indices, id: \.self) { index in
                            let slider = effect.sliders[index]
                            VStack {
                                Text(slider.name)
                                Slider(value: Binding(
                                    get: { effect.sliders[index].value },
                                    set: { newValue in
                                        imageProcessor.selectedEffect?.sliders[index].value = newValue
                                    }
                                ),
                                       in: slider.range,
                                       step: slider.step
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            effectsSelectionView
        }
    }
    
    var effectsSelectionView: some View{
        // Horizontal scroll of different color effect
        ScrollView(.horizontal, showsIndicators: true) {
            LazyHStack(spacing: 0) {
                ForEach(imageProcessor.effectImages) { effectImage in
                    let isSelected = (effectImage.effect == imageProcessor.selectedEffect)
                    
                    ProcessedImageView(effectImage: effectImage, isSelected: isSelected)
                        .onTapGesture {
                            imageProcessor.selectedEffect = effectImage.effect
                        }
                }
            }
            .frame(maxWidth: .infinity)  // Ensure HStack takes the entire available width
            .padding()
        }
    }

}

//#Preview {
//    PhotoEditingPreview(originalImage: NSImage(named: "ExampleOriginalImage")!,
//                        editedImage: NSImage(named: "ExampleEditedImage")!)
//}
