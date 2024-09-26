import Cocoa
import CoreImage
import PlaygroundSupport
import SwiftUI

// Define the function that applies the cartoon effect
public func applyCartoonEffect(to image: NSImage, edgeIntensity: Double = 3.0, blurRadius: Double = 2.0, posterizeLevels: Double = 6.0) -> NSImage? {
    guard let tiffData = image.tiffRepresentation,
          let ciImage = CIImage(data: tiffData) else { return nil }

    // Step 1: Apply a median filter to reduce noise
    guard let medianFilter = CIFilter(name: "CIMedianFilter") else { return nil }
    medianFilter.setValue(ciImage, forKey: kCIInputImageKey)
    guard let medianOutput = medianFilter.outputImage else { return nil }

    // Step 2: Convert the image to grayscale and apply edge detection
    guard let grayscaleFilter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
    grayscaleFilter.setValue(medianOutput, forKey: kCIInputImageKey)
    guard let grayscaleOutput = grayscaleFilter.outputImage else { return nil }
    
    guard let edgesFilter = CIFilter(name: "CIEdges") else { return nil }
    edgesFilter.setValue(grayscaleOutput, forKey: kCIInputImageKey)
    edgesFilter.setValue(edgeIntensity, forKey: kCIInputIntensityKey)
    guard let edgesOutput = edgesFilter.outputImage else { return nil }

    // Step 3: Dilate the edges (approximation using CI filters)
    guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
    maskToAlphaFilter.setValue(edgesOutput, forKey: kCIInputImageKey)
    guard let maskToAlphaOutput = maskToAlphaFilter.outputImage else { return nil }
    
    // Step 4: Apply bilateral filter to smooth the image while preserving edges
    guard let bilateralFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
    bilateralFilter.setValue(medianOutput, forKey: kCIInputImageKey)
    bilateralFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
    guard let bilateralOutput = bilateralFilter.outputImage else { return nil }

    // Step 5: Quantize the colors (Posterize)
    guard let posterizeFilter = CIFilter(name: "CIColorPosterize") else { return nil }
    posterizeFilter.setValue(bilateralOutput, forKey: kCIInputImageKey)
    posterizeFilter.setValue(posterizeLevels, forKey: "inputLevels")
    guard let posterizeOutput = posterizeFilter.outputImage else { return nil }

    // Step 6: Blend the edges with the posterized image
    guard let blendFilter = CIFilter(name: "CIMultiplyCompositing") else { return nil }
    blendFilter.setValue(maskToAlphaOutput, forKey: kCIInputImageKey)
    blendFilter.setValue(posterizeOutput, forKey: kCIInputBackgroundImageKey)
    guard let finalOutput = blendFilter.outputImage else { return nil }

    // Convert the final CIImage to NSImage
    let context = CIContext()
    guard let cgImage = context.createCGImage(finalOutput, from: finalOutput.extent) else { return nil }
    
    return NSImage(cgImage: cgImage, size: image.size)
}

// SwiftUI view to display and adjust the cartoon effect
struct CartoonEffectView: View {
    @State private var edgeIntensity: Double = 3.0
    @State private var blurRadius: Double = 2.0
    @State private var posterizeLevels: Double = 6.0
    @State private var originalImage = NSImage(named: "sample")!
    @State private var editedImage: NSImage?
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Original Image")
                    Image(nsImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .border(Color.blue, width: 2)
                }
                VStack {
                    Text("Cartoon Effect")
                    if let editedImage = editedImage {
                        Image(nsImage: editedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .border(Color.green, width: 2)
                    }
                }
            }
            
            VStack{
                Slider(value: $edgeIntensity, in: 10.0...200.0, step: 5.0, label: {
                    Text("Edge Intensity:\(edgeIntensity)")
                })
                Slider(value: $blurRadius, in: 10.0...200.0, step: 5.0, label: {
                    Text("Blur Radius:\(blurRadius)")
                })
                Slider(value: $posterizeLevels, in: 0.0...30.0, step: 1.0, label: {
                    Text("Posterize Levels:\(posterizeLevels)")
                })
                Button("Apply Cartoon Effect") {
                    apply()
                }
            }
            .frame(width: 600)
            .onChange(of: edgeIntensity){ apply() }
            .onChange(of: blurRadius){ apply() }
            .onChange(of: posterizeLevels){ apply() }
        }
        .padding()
        .onAppear {
            apply()
        }
    }
    
    func apply(){
        // Apply the effect once when the view appears
        editedImage = applyCartoonEffect(to: originalImage, edgeIntensity: edgeIntensity, blurRadius: blurRadius, posterizeLevels: posterizeLevels)
    }
}

// Create an NSImage from a file (replace "SampleImage.png" with your image file)
let imagePath = Bundle.main.path(forResource: "sample", ofType: "heic")!
let originalImage = NSImage(contentsOfFile: imagePath)!

// Display the view in the playground live view
PlaygroundPage.current.setLiveView(CartoonEffectView())
