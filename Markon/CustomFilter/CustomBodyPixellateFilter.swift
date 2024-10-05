//
//  CustomBodyPixellateFilter.swift
//  Markon
//
//  Created by Fan Yang on 04/10/2024.
//


//
//  CustomBodyPixellateFilter.swift
//  Markon
//
//  Created by [Your Name] on [Date].
//

import CoreImage
import Vision

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@objc(CustomBodyPixellateFilter)
class CustomBodyPixellateFilter: CIFilter {
    
    // MARK: - Input Properties
    
    @objc dynamic var inputImage: CIImage?
    /// Intensity of the pixellation effect. Range: 1.0 (low) to 100.0 (high).
    @objc dynamic var intensity: CGFloat = 10.0
    
    // MARK: - CIFilter Attributes
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Custom Body Pixellate Filter",
            
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
            print("CustomBodyPixellateFilter: Failed to create CGImage from input.")
            return nil
        }
        
        // Create a Vision request for human body detection
        let request = VNDetectHumanRectanglesRequest()
        request.upperBodyOnly = false
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform the request synchronously
        do {
            try handler.perform([request])
        } catch {
            print("CustomBodyPixellateFilter: Vision request failed with error: \(error)")
            return nil
        }
        
        guard let observations = request.results as? [VNDetectedObjectObservation], !observations.isEmpty else {
            // No bodies detected, return the original image
            return inputImage
        }
        
        // Begin processing
        var finalImage = inputImage
        
        for body in observations {
            // Convert Vision coordinates to Core Image coordinates
            let boundingBox = body.boundingBox
            let imageSize = inputImage.extent.size
            
            // Vision's boundingBox has origin at bottom-left
            let bodyRect = CGRect(
                x: boundingBox.origin.x * imageSize.width,
                y: boundingBox.origin.y * imageSize.height,
                width: boundingBox.size.width * imageSize.width,
                height: boundingBox.size.height * imageSize.height
            )
            
            // Create a mask for the body region
            guard let maskImage = createRectangularMask(for: bodyRect, in: inputImage.extent) else { continue }
            
            // Apply pixellation to the body region
            let pixellate = CIFilter.crystallize()
            pixellate.inputImage = finalImage
            pixellate.radius = Float(intensity)
            guard let pixellatedImage = pixellate.outputImage else { continue }
            
            // Blend the pixellated image with the original image using the mask
            let blendWithMask = CIFilter.blendWithMask()
            blendWithMask.inputImage = pixellatedImage
            blendWithMask.backgroundImage = finalImage
            blendWithMask.maskImage = maskImage
            guard let blendedImage = blendWithMask.outputImage else { continue }
            
            // Update the final image
            finalImage = blendedImage
        }
        
        return finalImage
    }
    
    // MARK: - Helper Methods
    
    /// Creates a rectangular mask for the given body rectangle.
    /// - Parameters:
    ///   - rect: The bounding rectangle of the detected body.
    ///   - extent: The extent of the entire image.
    /// - Returns: A CIImage representing the rectangular mask.
    private func createRectangularMask(for rect: CGRect, in extent: CGRect) -> CIImage? {
        // Create a black background image
        let blackBackground = CIImage(color: CIColor.black).cropped(to: extent)
        
        // Create a white rectangle image for the body region
        let whiteRectangle = CIImage(color: CIColor.white).cropped(to: rect)
        
        // Composite the white rectangle over the black background
        let maskImage = whiteRectangle.composited(over: blackBackground)
        
        return maskImage
    }
}
