////
////  GPUImageEffect.swift
////  Markon
////
////  Created by Fan Yang on 08/09/2024.
////
//
//import Foundation
////import AppKit
//import GPUImage
//
//struct GPUImageEffect {
//
//}
//
//
//extension GPUImageEffect{
//    //GPUImage effects
//#if os(macOS)
//    static let GPUImageEffects: [MarkonEffect] = [
//        cartoon,
//        pixellate,
//        
//        
//        polkaDot,
//        halftone,
//        crosshatch,
//        sketch,
//        thresholdSketch,
//        emboss
//       
//    ]
//#elseif os(iOS)
//    // memory is limited in iOS
//    static let GPUImageEffects: [MarkonEffect] = [
//        cartoon,
//        pixellate,
////        polkaDot,
////        halftone,
////        crosshatch,
////        sketch,
////        thresholdSketch,
////        emboss
////       
//    ]
//    
//#endif
//    
//    
//    static func GPUImageFilter4(filterID: String, params: [Float]) -> ImageProcessingOperation? {
//        switch filterID {
//        case "GPUImage_Cartoon":
//            let filter = SmoothToonFilter()
//            filter.threshold = params[0]
//            filter.blurRadiusInPixels = params[1]
//            filter.quantizationLevels = params[2]
//            return filter
//            
//        case "GPUImage_Pixellate":
//            let filter = Pixellate()
//            filter.fractionalWidthOfAPixel = params[0]
//            return filter
//            
//        case "GPUImage_PolkaDot":
//            let filter = PolkaDot()
//            filter.fractionalWidthOfAPixel = params[0]
//            filter.dotScaling = params[1]
//            return filter
//            
//        case "GPUImage_Halftone":
//            let filter = Halftone()
//            filter.fractionalWidthOfAPixel = params[0]
//            return filter
//            
//        case "GPUImage_Crosshatch":
//            let filter = Crosshatch()
//            filter.crossHatchSpacing = params[0]
//            filter.lineWidth = params[1]
//            return filter
//            
//        case "GPUImage_Sketch":
//            let filter = SketchFilter()
//            filter.edgeStrength = params[0]
//            return filter
//            
//        case "GPUImage_Threshold_Sketch":
//            let filter = ThresholdSketchFilter()
//            filter.edgeStrength = params[0]
//            filter.threshold = params[1]
//            return filter
//            
//        case "GPUImage_Emboss":
//            let filter = EmbossFilter()
//            filter.intensity = params[0]
//            return filter
//            
//        default:
//            print("GPUImageEffects GPUFilter4 warning: unknown filterID: \(filterID)")
//            return nil
//        }
//    }
//    
//    static let cartoon = MarkonEffect(
//        id: "GPUImage_Cartoon",
//        name: "Cartoon",
//        sliders: [
//            SliderInfo(name: "Threshold", range: 0.01...0.2, step: 0.01, value: 0.2),
//            SliderInfo(name: "Blur Radius", range: 1.0...10.0, step: 1.0, value: 2.0),
//            SliderInfo(name: "Quantization Levels", range: 1.0...25.0, step: 1.0, value: 6.0)
//        ]
//    )
//    
//    static let pixellate = MarkonEffect (
//        id: "GPUImage_Pixellate",
//        name: "Pixellate",
//        sliders: [
//            SliderInfo(name: "fractionalWidth", range: 0.0...0.25, step: 0.01, value: 0.05)
//        ]
//    )
//    
//    static let polkaDot = MarkonEffect (
//        id: "GPUImage_PolkaDot",
//        name: "PolkaDot",
//        sliders: [
//            SliderInfo(name: "fractionalWidth", range: 0.0...0.1, step: 0.005, value: 0.02),
//            SliderInfo(name: "dotScaling", range: 0.5...1.0, step: 0.02, value: 0.9)
//        ]
//    )
//    
//    static let halftone = MarkonEffect (
//        id: "GPUImage_Halftone",
//        name: "Halftone",
//        sliders: [
//            SliderInfo(name: "fractionalWidth", range: 0.0...0.2, step: 0.01, value: 0.05)
//        ]
//    )
//    
//    static let crosshatch = MarkonEffect (
//        id: "GPUImage_Crosshatch",
//        name: "Crosshatch",
//        sliders: [
//            SliderInfo(name: "crossHatchSpacing", range: 0.0...0.2, step: 0.01, value: 0.03),
//            SliderInfo(name: "lineWidth", range: 0.0001...0.002, step: 0.0001, value: 0.003)
//        ]
//    )
//    
//    static let sketch = MarkonEffect (
//        id: "GPUImage_Sketch",
//        name: "Sketch",
//        sliders: [
//            SliderInfo(name: "edgeStrength", range: 0.5...10, step: 0.5, value: 1),
//        ]
//    )
//
//    static let thresholdSketch = MarkonEffect (
//        id: "GPUImage_Threshold_Sketch",
//        name: "Threshold Sketch",
//        sliders: [
//            SliderInfo(name: "edgeStrength", range: 0.5...10, step: 0.5, value: 1),
//            SliderInfo(name: "Threshold", range: 0.1...1.0, step: 0.05, value: 0.8),
//        ]
//    )
//    
//    static let emboss = MarkonEffect (
//        id: "GPUImage_Emboss",
//        name: "Emboss",
//        sliders: [
//            SliderInfo(name: "intensity", range: 0.0...4, step: 0.5, value: 1),
//        ]
//    )
//}
