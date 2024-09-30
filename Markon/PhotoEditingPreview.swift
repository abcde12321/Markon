//
//  PhotoEditingPreview.swift
//  MarkonExtension
//
//  Created by Fan Yang on 08/08/2024.
//

import SwiftUI

struct PhotoEditingPreview: View {
    
    @StateObject var imageProcessor = CIFilterProcessor.shared
    
    @State private var showingExporter = false
    @State private var shareItem: PlatformImage? = nil
    
    var body: some View {
        VStack {
            HStack{
                if imageProcessor.selectedEffect != nil {
                    processedImageView
                }
                
                // Sliders for selected effect
                let ow:CGFloat = (imageProcessor.selectedEffect == nil ? CGFloat.infinity : 300)
                VStack {
                    //if no select effect, show original image, when selected, make original image smaller
                    if imageProcessor.originalImage != nil{
                        originalImageView
                    }
                    
                    // effect parameters adjustment sliders
                    if let effect = imageProcessor.selectedEffect {
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
                            //.background(.gray)
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: ow)
            }
            .frame(maxHeight: .infinity) // Ensure HStack takes full width
            //.background(.green)
            effectsSelectionView
                //.background(.blue)
                .frame(height: 250)
        }
        .frame(maxHeight: .infinity)
    }
    
    var processedImageView: some View{
        VStack {

            
            if let image = imageProcessor.processedImage{
                let exportImage = Image(platformImage: image)
                
                ShareLink(item: exportImage, preview: SharePreview("", image: exportImage)){
                    Text("Export Image")
                }
                
                Image(platformImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(maxHeight: .infinity) // Allow VStack to expand
        .padding()
        //.background(.yellow)
    }
    
    var originalImageView: some View {
        VStack {
            Text("Original Image")
            ZStack(alignment: .topTrailing) {
                Image(platformImage: imageProcessor.originalImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Button(action: {
                    imageProcessor.originalImage = nil
                }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle()) // Ensures consistent appearance on both platforms
            }
        }
        .frame(minHeight: 250)
        .padding()
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
        }
    }
}



//extension PhotoEditingPreview{
//
//    func showSharingPicker(for url: URL) {
//        #if os(macOS)
//        // Function to show the NSSharingServicePicker in the center of the window
//        let sharingPicker = NSSharingServicePicker(items: [url])
//        
//        if let window = NSApp.keyWindow {
//            let windowFrame = window.contentView?.frame ?? .zero
//            let pickerOrigin = CGPoint(
//                x: windowFrame.midX - 150,  // Adjust to center horizontally
//                y: windowFrame.midY - 75    // Adjust to center vertically
//            )
//            
//            // Show the sharing picker at the center of the window
//            sharingPicker.show(relativeTo: NSRect(origin: pickerOrigin, size: .zero), of: window.contentView!, preferredEdge: .minY)
//        }
//        #elseif os(iOS)
//            //iOSshowShareSheet = true
//        #endif
//    }
//    
//    
//    func getTempFileURL() -> URL {
//        let tempDir = FileManager.default.temporaryDirectory
//        let fileURL = tempDir.appendingPathComponent("processed_image.jpg")
//        return fileURL
//    }
//    
//    // Helper function to save the image to a temporary file for macOS sharing
//    func saveImageToTempFile(_ image: PlatformImage) -> URL? {
//        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
//        //let tempDir = FileManager.default.temporaryDirectory
//        let fileURL = getTempFileURL()
//        
//        do {
//            try data.write(to: fileURL)
//            return fileURL
//        } catch {
//            print("Failed to save image: \(error)")
//            return nil
//        }
//    }
//}

//#Preview {
//    PhotoEditingPreview(originalImage: NSImage(named: "ExampleOriginalImage")!,
//                        editedImage: NSImage(named: "ExampleEditedImage")!)
//}
