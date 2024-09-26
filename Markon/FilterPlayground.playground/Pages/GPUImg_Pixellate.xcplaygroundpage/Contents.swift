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
    @State private var threshold: Float = 0.01
    @State private var center: Float = 0.5
    @State private var pixelSize: Float = 0.05
    
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
            Slider(value: $threshold, in: 0...0.1, step: 0.001)
                .padding()
                .onChange(of: threshold){ applyFilter() }
            
            Text("center: (\(center), \(center))")
            Slider(value: $center, in: 0...1, step: 0.01)
                .padding()
                .onChange(of: center){ applyFilter() }
            
            Text("pixelSize: \(pixelSize)")
            Slider(value: $pixelSize, in: 0...1, step: 0.05)
                .padding()
                .onChange(of: pixelSize){ applyFilter() }
            
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
        let filter = Pixellate()
        filter.fractionalWidthOfAPixel = threshold
        //filter.center = Position(center, center)
        //filter.pixelSize = Size(width: pixelSize, height: pixelSize)
        
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
