//: [Previous](@previous)

import Foundation
import GPUImage
import SwiftUI
import AppKit
import PlaygroundSupport



let imagePath = Bundle.main.path(forResource: "sample", ofType: "heic")!
let originalImage = NSImage(contentsOfFile: imagePath)!


// Define a SwiftUI view to display the images and slider
struct ContentView: View {
    @State private var threshold: Float = 0.5
    @State private var edgeStrength: Float = 2
    //@State private var quantizationLevels: Float = 10
    
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
            
            Text("Threshold: \(threshold)")
            Slider(value: $threshold, in: 0...1, step: 0.05)
                .padding()
                .onChange(of: threshold){ applyFilter() }
            
            Text("blurRadiusInPixels: \(edgeStrength)")
            Slider(value: $edgeStrength, in: 0...15, step: 1)
                .padding()
                .onChange(of: edgeStrength){ applyFilter() }
    
            
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
        let toonFilter = ThresholdSketchFilter()
        toonFilter.threshold = threshold
        toonFilter.edgeStrength = edgeStrength
        
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
        
        pictureInput --> toonFilter --> pictureOutput
        pictureInput.processImage(synchronously: true)
    }
}

PlaygroundPage.current.setLiveView(ContentView())


    
// MARK: - Section 2: ScachFilter
