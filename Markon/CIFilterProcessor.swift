//
//  CIFilterProcessor.swift
//  Markon
//
//  Created by Fan Yang on 27/09/2024.
//


import CoreImage
import SwiftUI

struct EffectImage: Identifiable {
    var id: String { effect.id }
    let effect: MarkonEffect
    var image: PlatformImage?
}

class CIFilterProcessor: ObservableObject {
    static let shared = CIFilterProcessor()
    var downScaleSize = CGSize(width: 200, height: 200)

    @Published var effectImages: [EffectImage] = CIFilterEffect.CIFilterEffects.map { EffectImage(effect: $0) }

    @Published var selectedEffect: MarkonEffect? {
        didSet {
            Task {
                guard let effect = selectedEffect else { return }
                print("CIFilterProcessor selectedEffect \(effect)")
                
                guard let inputImage = ciInputImage else { return }
                let processedImage = await processEffect(effect, on: inputImage)

                await MainActor.run {
                    self.processedImage = processedImage
                }
            }
        }
    }

    @Published var originalImage: PlatformImage? {
        didSet {
            print("CIFilterProcessor originalImage didSet")

            guard let image = originalImage else {
                processedImage = nil
                return
            }

            ciInputImage = CIImage(platformImage:image)
            Task {
                await processAllEffectsLight()
            }
        }
    }

    @Published var processedImage: PlatformImage?

    var ciInputImage: CIImage?

    private func processEffect(_ effect: MarkonEffect, on ciImage: CIImage) async -> PlatformImage? {
        print("CIFilterProcessor processEffect", effect)
        
        guard let filter = effect.cifilter else {
            print("CIFilterProcessor processEffect generate filter failed: \(effect)")
            return nil
        }

        if let processedImage = await applyCIFilter(filter, to: ciImage) {
            return processedImage
        } else {
            print("CIFilterProcessor processEffect failed")
            return nil
        }
    }
    
    func processAllEffectsLight() async {
        guard let ciInputImage = ciInputImage else { return }

        guard let downscaledImage = ciInputImage.downscaled(to: downScaleSize) else { return }
        
        for index in effectImages.indices {
            let effect = effectImages[index].effect
            let processedImage = await processEffect(effect, on: downscaledImage)
            DispatchQueue.main.async {
                self.effectImages[index].image = processedImage
            }
        }
    }

    private func applyCIFilter(_ filter: CIFilter, to ciImage: CIImage) async -> PlatformImage? {
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        if let outputImage = filter.outputImage {
            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                #if os(iOS)
                return UIImage(cgImage: cgImage)
                #elseif os(macOS)
                return NSImage(cgImage: cgImage, size: outputImage.extent.size)
                #endif
            }
        }
        return nil
    }
}
