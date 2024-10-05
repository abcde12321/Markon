//
//  ScratchyFilmFilter.swift
//  Markon
//
//  Created by Fan Yang on 27/09/2024.
//


import CoreImage
import CoreImage.CIFilterBuiltins
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class ScratchyFilmFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage else { return nil }
        
        //Tint the original image by applying the sepiaTone() filter.
        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.inputImage = inputImage
        sepiaFilter.intensity = 1.0
        let sepiaCIImage = sepiaFilter.outputImage
        
        //generate noise image
        let colorNoise = CIFilter.randomGenerator()
        guard let noiseImage = colorNoise.outputImage else {
            print("ScratchyFilmFilter generate noiseImage error")
            return nil
        }
        
        //apply a whitening effect by chaining the noise output to a colorMatrix() filter
        let whitenVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        let fineGrain = CIVector(x:0, y:0.005, z:0, w:0)
        let zeroVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        let whiteningFilter = CIFilter.colorMatrix()
        whiteningFilter.inputImage = noiseImage
        whiteningFilter.rVector = whitenVector
        whiteningFilter.gVector = whitenVector
        whiteningFilter.bVector = whitenVector
        whiteningFilter.aVector = fineGrain
        whiteningFilter.biasVector = zeroVector
        let whiteSpecks = whiteningFilter.outputImage
        
        //Create the grainy image by compositing the whitened noise as input over the sepia-toned source image using the sourceOverCompositing() filter.
        let speckCompositor = CIFilter.sourceOverCompositing()
        speckCompositor.inputImage = whiteSpecks
        speckCompositor.backgroundImage = sepiaCIImage
        let speckledImage = speckCompositor.outputImage
        
        
        //Simulate Scratch by Scaling Randomly Varying Noise
        let verticalScale = CGAffineTransform(scaleX: 1.5, y: 25)
        let transformedNoise = noiseImage.transformed(by: verticalScale)
        
        let darkenVector = CIVector(x: 4, y: 0, z: 0, w: 0)
        let darkenBias = CIVector(x: 0, y: 1, z: 1, w: 1)
        let darkeningFilter = CIFilter.colorMatrix()
        darkeningFilter.inputImage = transformedNoise //noiseImage
        darkeningFilter.rVector = darkenVector
        darkeningFilter.gVector = zeroVector
        darkeningFilter.bVector = zeroVector
        darkeningFilter.aVector = zeroVector
        darkeningFilter.biasVector = darkenBias
        let randomScratches = darkeningFilter.outputImage
        
        let grayscaleFilter = CIFilter.minimumComponent()
        grayscaleFilter.inputImage = randomScratches
        let darkScratches = grayscaleFilter.outputImage
        
        //Composite the Specks and Scratches to the Sepia Image
        let oldFilmCompositor = CIFilter.multiplyCompositing()
        oldFilmCompositor.inputImage = darkScratches
        oldFilmCompositor.backgroundImage = speckledImage
        guard let oldFilmImage = oldFilmCompositor.outputImage else {
            print("ScratchyFilmFilter generate oldFilmImage error")
            return nil
        }
        
        let finalImage = oldFilmImage.cropped(to: inputImage.extent)
        
        return finalImage
    }
}
