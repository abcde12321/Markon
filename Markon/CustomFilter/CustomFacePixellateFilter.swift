//
//  CustomFacePixellateFilter.swift
//  Markon
//
//  Created by Fan Yang on 04/10/2024.
//


import CoreImage
import Vision

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@objc(CustomFacePixellateFilter)
class CustomFacePixellateFilter: CIFilter {
    
    // MARK: - Input Properties
    
    @objc dynamic var inputImage: CIImage?
    /// Intensity of the pixellation effect. Range: 1.0 (low) to 100.0 (high).
    @objc dynamic var intensity: CGFloat = 10.0
    
    // MARK: - CIFilter Attributes
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Custom Face Pixellate Filter",
            
            "inputImage": [
                kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Input Image",
                kCIAttributeType: kCIAttributeTypeImage
            ],
            
            "intensity": [
                kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDisplayName: "Intensity",
                kCIAttributeDefault: 10.0,
                kCIAttributeMin: 1.0,
                kCIAttributeMax: 100.0,
                kCIAttributeSliderMin: 1.0,
                kCIAttributeSliderMax: 100.0,
                kCIAttributeType: kCIAttributeTypeScalar
            ]
        ]
    }
    
    // MARK: - Output Image
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        
        // Create a CIContext
        let context = CIContext(options: nil)
        
        // Convert CIImage to CGImage
        guard let cgImage = context.createCGImage(inputImage, from: inputImage.extent) else {
            print("CustomFacePixellateFilter: Failed to create CGImage from input.")
            return nil
        }
        
        // Create a Vision request for face detection
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform the request synchronously
        do {
            try handler.perform([request])
        } catch {
            print("CustomFacePixellateFilter: Vision request failed with error: \(error)")
            return nil
        }
        
        guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty else {
            // No faces detected, return the original image
            return inputImage
        }
        
        // Begin processing
        var finalImage = inputImage
        
        for face in observations {
            // Convert Vision coordinates to Core Image coordinates
            let boundingBox = face.boundingBox
            let imageSize = inputImage.extent.size
            
            // **Correct Y-coordinate inversion**
            // Vision's boundingBox has origin at bottom-left; Core Image also has origin at bottom-left
            // However, if the image is being displayed in a context with a different origin (e.g., UIKit),
            // ensure that the mask is created correctly. For Core Image processing, the coordinates are consistent.
            let faceRect = CGRect(
                x: boundingBox.origin.x * imageSize.width,
                y: boundingBox.origin.y * imageSize.height,
                width: boundingBox.size.width * imageSize.width,
                height: boundingBox.size.height * imageSize.height
            )
            
            // **Create a mask for the face region**
            guard let maskImage = createEllipticalMask(for: faceRect, in: inputImage.extent) else { continue }
            
            // **Apply pixellation to the face region**
            let pixellate = CIFilter.crystallize()
            pixellate.inputImage = finalImage
            pixellate.radius = Float(intensity)
            guard let pixellatedImage = pixellate.outputImage else { continue }
            
            
            
            // **Blend the pixellated image with the original image using the mask**
            let blendWithMask = CIFilter.blendWithMask()
            blendWithMask.inputImage = pixellatedImage
            blendWithMask.backgroundImage = finalImage
            blendWithMask.maskImage = maskImage
            guard let blendedImage = blendWithMask.outputImage else { continue }
            
            // **Update the final image**
            finalImage = blendedImage
        }
        
        return finalImage
    }
    
    // MARK: - Helper Methods
    
    /// Creates an elliptical mask for the given face rectangle.
    /// - Parameters:
    ///   - rect: The bounding rectangle of the detected face.
    ///   - extent: The extent of the entire image.
    /// - Returns: A CIImage representing the elliptical mask.
    private func createEllipticalMask(for rect: CGRect, in extent: CGRect) -> CIImage? {
        // 1. Define the new center at the top 1/4 of the rect
        let centerX = rect.midX
        let centerY = rect.midY + (rect.height * 0.25)
        let center = CIVector(x: centerX, y: centerY)
        
        // 2. Set radius0 to the original width of the rect
        let radius0: CGFloat = rect.width / 1.2
        
        // 3. Define radius1 based on transitionWidth
        let transitionWidth: CGFloat = radius0 * 0.3 // Adjust as needed for sharper or smoother edges
        let radius1: CGFloat = radius0 + transitionWidth
        
        // 4. Create the CIRadialGradient filter
        guard let radialGradientFilter = CIFilter(name: "CIRadialGradient") else {
            print("CustomFacePixellateFilter: Failed to create CIRadialGradient filter.")
            return nil
        }
        
        radialGradientFilter.setValue(center, forKey: "inputCenter")
        radialGradientFilter.setValue(radius0, forKey: "inputRadius0")
        radialGradientFilter.setValue(radius1, forKey: "inputRadius1")
        radialGradientFilter.setValue(CIColor(color: .white), forKey: "inputColor0") // Opaque center
        radialGradientFilter.setValue(CIColor(color: .black), forKey: "inputColor1") // Transparent edges
        
        // 5. Generate the radial gradient image and crop it to the extent
        guard var gradientImage = radialGradientFilter.outputImage?.cropped(to: extent) else {
            print("CustomFacePixellateFilter: Failed to generate radial gradient image.")
            return nil
        }
        
        return gradientImage
    }
}
