//
//  GPUImageProcessor.swift
//  Markon
//
//  Created by Fan Yang on 09/09/2024.
//

import Foundation
//import AppKit
import GPUImage


struct EffectImage: Identifiable {
    var id: String { effect.id }
    let effect: MarkonEffect
    var image: PlatformImage?
}

class GPUImageProcessor: ObservableObject {
    static let shared = GPUImageProcessor()
    
    @Published var effectImages: [EffectImage] = GPUImageEffect.GPUImageEffects.map { EffectImage(effect: $0) }
    
    @Published var selectedEffect:MarkonEffect? {
        didSet{
            Task{
                guard let effect = selectedEffect else { return }
                print("GPUImageProcessor selectedEffect \(effect)")
                let processedImage = await processEffect(effect)
                
                await MainActor.run {
                    self.processedImage = processedImage
                }
            }
        }
    }
    
    @Published var originalImage:PlatformImage?{
        didSet{
            print("GPUImageProcessor originalImage didSet")
            
            guard let image = originalImage else {
                processedImage = nil
                return
            }
            
            pictureInput = PictureInput(image: image)
            Task {
                for index in effectImages.indices {
                    let effect = effectImages[index].effect
                    let processedImage = await processEffect(effect)
                    DispatchQueue.main.async { // Ensure UI updates happen on the main thread
                        self.effectImages[index].image = processedImage
                    }
                }
            }
        }
    }
    
    @Published var processedImage:PlatformImage? //using selectedEffect
    //@Published var processedImages:[NSImage] = []
    
    var pictureInput:PictureInput!
    
    
    
    
    private func processEffect(_ effect:MarkonEffect) async -> PlatformImage?{
        print("GPUImageProcessor processEffect", effect)
        
        //let pictureInput = PictureInput(image: image)
        
        guard let filter = GPUImageEffect.GPUImageFilter4(filterID: effect.id, params: effect.sliders.map { Float($0.value)} ) else{
            print("GPUImageProcessor processEffect generate filter failed: \(effect)")
            return nil
        }
        
        if let processedImage = await applyGPUImageFilter(filter){
            return processedImage
        }else{
            print("GPUImageProcessor processEffect failed")
            return nil
        }
    }
    
    private func applyGPUImageFilter(_ filter: ImageProcessingOperation) async -> PlatformImage?{
        return await withCheckedContinuation { continuation in
            let pictureOutput = PictureOutput()
            var hasResumed = false  // Flag to prevent multiple resumes
            
            pictureOutput.encodedImageAvailableCallback = { imageData in
                guard !hasResumed else { return }  // Exit if already resumed
                hasResumed = true  // Mark as resumed
                
                if let outputImage = PlatformImage(data: imageData) {
                    // Resume continuation with the processed image
                    continuation.resume(returning: outputImage)
                } else {
                    // If the output image could not be created, return nil
                    continuation.resume(returning: nil)
                }
            }
            pictureInput --> filter --> pictureOutput
            pictureInput.processImage(synchronously: true)
        }
    }

}


//actor GPUImageProcessor {
//    static let shared = GPUImageProcessor()
//
//    func processImage(effect: CustomEffect, originalImage: NSImage, params: [Double]) async -> NSImage? {
//        print("GPUImageProcessor", effect.name, "starts")
//        
//        let processedImage = await effect.applyEffect(originalImage, params)
//
//        print("GPUImageProcessor", effect.name, "finish processing image")
//        return processedImage
//    }
//
//}

