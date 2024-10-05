//
//  CustomML_pencil.swift
//  Markon
//
//  Created by Fan Yang on 03/10/2024.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreML

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif


class CustomML_pencilFilter: CIFilter {
    // MARK: - Input Properties
    
    @objc dynamic var inputImage: CIImage?

    
    // MARK: - Output Image
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        
//        // 1. Apply blur
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = inputImage
        guard let preProcessedImage = filter.outputImage else {
            print("CustomML_pencilFilter: Edge detection failed.")
            return nil
        }
        
        // 2. Apply Core ML Filter
        let coreMLFilter = CIFilter.coreMLModel()
        
        if let model = try? CustomML_pencil(configuration: .init()).model{
            coreMLFilter.inputImage = preProcessedImage
            coreMLFilter.model = model
            return coreMLFilter.outputImage
        }else{
            return nil
        }
    }
}
