//
//  CustomBackgroundPixellateFilter.swift
//  Markon
//
//  Created by Fan Yang on 05/10/2024.
//


//
//  CustomBackgroundPixellateFilter.swift
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

@objc(CustomBackgroundPixellateFilter)
class CustomBackgroundPixellateFilter: CIFilter {
    
    // MARK: - Input Properties
    
    @objc dynamic var inputImage: CIImage?
    /// Intensity of the pixellation effect. Range: 1.0 (low) to 100.0 (high).
    @objc dynamic var intensity: CGFloat = 10.0
    
    // MARK: - CIFilter Attributes
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Custom Background Pixellate Filter",
            
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
            print("CustomBackgroundPixellateFilter: Failed to create CGImage from input.")
            return nil
        }
        
        // Create a Vision request for human body detection
        let request = VNDetectHumanRectanglesRequest()
        request.upperBodyOnly = false // Detect full body
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform the request synchronously
        do {
            try handler.perform([request])
        } catch {
            print("CustomBackgroundPixellateFilter: Vision request failed with error: \(error)")
            return nil
        }
        
        guard let observations = request.results as? [VNDetectedObjectObservation], !observations.isEmpty else {
            // No bodies detected, pixellate the entire image
            let pixellate = CIFilter.crystallize()
            pixellate.inputImage = inputImage
            pixellate.radius = Float(intensity)
            return pixellate.outputImage
        }
        
        // Begin processing
        var maskImage = CIImage(color: CIColor.white).cropped(to: inputImage.extent)
        
        let imageSize = inputImage.extent.size
        
        for body in observations {
            // Convert Vision coordinates to Core Image coordinates
            let boundingBox = body.boundingBox
            let bodyRect = CGRect(
                x: boundingBox.origin.x * imageSize.width,
                y: boundingBox.origin.y * imageSize.height,
                width: boundingBox.size.width * imageSize.width,
                height: boundingBox.size.height * imageSize.height
            )
            
            // Create a black rectangle image for the body region
            let blackRectangle = CIImage(color: CIColor.black).cropped(to: bodyRect)
            
            // Composite the black rectangle over the mask image
            maskImage = blackRectangle.composited(over: maskImage)
        }
        
        // Apply pixellation to the entire image
        let pixellate = CIFilter.crystallize()
        pixellate.inputImage = inputImage
        pixellate.radius = Float(intensity)
        guard let pixellatedImage = pixellate.outputImage else {
            return nil
        }
        
        // Blend the original image with the pixellated image using the mask
        let blendWithMask = CIFilter.blendWithMask()
        blendWithMask.inputImage = pixellatedImage
        blendWithMask.backgroundImage = inputImage
        blendWithMask.maskImage = maskImage
        guard let finalImage = blendWithMask.outputImage else {
            return nil
        }
        
        return finalImage
    }
}
