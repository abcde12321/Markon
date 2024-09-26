//: [Previous](@previous)

import Foundation
import GPUImage
import SwiftUI
import AppKit
import PlaygroundSupport



let imagePath = Bundle.main.path(forResource: "sample2", ofType: "jpeg")!
let originalImage = NSImage(contentsOfFile: imagePath)!


// Define a SwiftUI view to display the images and slider
struct ContentView: View {
    @State private var radius: Float = 3
    
    @State private var filteredImage: NSImage?
    
    var body: some View {
        VStack{
            VStack {
                Text("Original Image")
                    .font(.headline)
                Image(nsImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 400)
                    .border(Color.black)
                
                Text("Filtered Image")
                    .font(.headline)
                if let filteredImage = filteredImage {
                    Image(nsImage: filteredImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 600, height: 800)
                        .border(Color.black)
                } else {
                    Text("Processing...")
                }
                
                
            }
            
            Text("radius: \(radius)")
            Slider(value: $radius, in: 0...20, step: 1)
                .padding()
                .onChange(of: radius){ applyFilter() }
            
            Button(action: applyFilter) {
                Text("Apply Filter")
            }
        }
        .frame(width: 800, height: 1500) // Adjust the frame size here
        .padding()
        .onAppear {
            applyFilter()
        }
    }
    
    func applyFilter() {
        // Create the toon filter and set the threshold
        let filter = KuwaharaRadius3Filter()
        //filter.radius = radius
        
        // Process the image
        let pictureInput = PictureInput(image: originalImage)
        let pictureOutput = PictureOutput()
        pictureOutput.encodedImageAvailableCallback = { imageData in
            if let outputImage = NSImage(data: imageData) {
                //DispatchQueue.main.async {
                    self.filteredImage = outputImage
                //}
            }
        }
        
        pictureInput --> filter --> pictureOutput
        pictureInput.processImage(synchronously: true)
    }
}

PlaygroundPage.current.setLiveView(ContentView())


    
// MARK: - Section 2: ScachFilter
