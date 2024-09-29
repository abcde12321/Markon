//
//  CIFilterEffect.swift
//  Markon
//
//  Created by Fan Yang on 27/09/2024.
//

import CoreImage
import SwiftUI
import CoreImage.CIFilterBuiltins

struct CIFilterEffect {
    // List of CIFilter-based MarkonEffects
    static let CIFilterEffects: [MarkonEffect] = [
        sepia,
        bloom,
        comicEffect,
        noir,
        crystallize,
        pointillize,
        pixellate,
        vignette,
        monochrome,
        invert,
        
        // New effects
        bokehBlur,
        gaussianBlur,
        morphologyMaximum,
        photoEffectTonal,
        colorPosterize,
        //circleSplashDistortion,
        //droste,
        glassDistortion,
        circularScreen,
        cmykHalftone,
        dotScreen,
        hatchedScreen,
        lineScreen,
        cannyEdgeDetector,//only available > ios17
        edges,
        edgeWork,
        gloom,
        gaborGradients,
        hexagonalPixellate,
        lineOverlay,
        sobelGradients,
        xRay,
        scratchyFilm
    ]

    // MARK: - MarkonEffect Definitions

    static let sepia = MarkonEffect(
        id: "CIFilter_Sepia",
        name: "Sepia",
        sliders: [
            SliderInfo(name: "Intensity", range: 0.0...1.0, step: 0.1, value: 0.8)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputIntensityKey)
            return filter
        }
    )

    static let bloom = MarkonEffect(
        id: "CIFilter_Bloom",
        name: "Bloom",
        sliders: [
            SliderInfo(name: "Intensity", range: 0.0...1.0, step: 0.1, value: 0.5),
            SliderInfo(name: "Radius", range: 0.0...100.0, step: 10.0, value: 10.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIBloom") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputIntensityKey)
            filter.setValue(effect.params[1], forKey: kCIInputRadiusKey)
            return filter
        }
    )

    static let comicEffect = MarkonEffect(
        id: "CIFilter_ComicEffect",
        name: "Comic Effect",
        sliders: [],
        cifilterProvider: { _ in
            return CIFilter(name: "CIComicEffect")
        }
    )

    static let noir = MarkonEffect(
        id: "CIFilter_Noir",
        name: "Noir",
        sliders: [],
        cifilterProvider: { _ in
            return CIFilter(name: "CIPhotoEffectNoir")
        }
    )

    static let crystallize = MarkonEffect(
        id: "CIFilter_Crystallize",
        name: "Crystallize",
        sliders: [
            SliderInfo(name: "Radius", range: 1.0...50.0, step: 1.0, value: 20.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CICrystallize") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputRadiusKey)
            return filter
        }
    )

    static let pointillize = MarkonEffect(
        id: "CIFilter_Pointillize",
        name: "Pointillize",
        sliders: [
            SliderInfo(name: "Radius", range: 1.0...30.0, step: 1.0, value: 20.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIPointillize") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputRadiusKey)
            return filter
        }
    )

    static let pixellate = MarkonEffect(
        id: "CIFilter_Pixellate",
        name: "Pixellate",
        sliders: [
            SliderInfo(name: "Scale", range: 1.0...100.0, step: 5.0, value: 8.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIPixellate") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputScaleKey)
            return filter
        }
    )

    static let vignette = MarkonEffect(
        id: "CIFilter_Vignette",
        name: "Vignette",
        sliders: [
            SliderInfo(name: "Intensity", range: 0.0...2.0, step: 0.1, value: 1.0),
            SliderInfo(name: "Radius", range: 0.0...5.0, step: 0.1, value: 1.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIVignette") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputIntensityKey)
            filter.setValue(effect.params[1], forKey: kCIInputRadiusKey)
            return filter
        }
    )

    static let monochrome = MarkonEffect(
        id: "CIFilter_Monochrome",
        name: "Monochrome",
        sliders: [
            SliderInfo(name: "Intensity", range: 0.0...1.0, step: 0.1, value: 1.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIColorMonochrome") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputIntensityKey)
            // Optionally set color parameter if needed
            filter.setValue(CIColor.black, forKey: kCIInputColorKey)
            return filter
        }
    )

    static let invert = MarkonEffect(
        id: "CIFilter_Invert",
        name: "Invert",
        sliders: [],
        cifilterProvider: { _ in
            return CIFilter(name: "CIColorInvert")
        }
    )
    
    static let bokehBlur = MarkonEffect(
        id: "CIFilter_BokehBlur",
        name: "Bokeh Blur",
        sliders: [
            SliderInfo(name: "Radius", range: 0.0...100.0, step: 5.0, value: 20.0),
            SliderInfo(name: "Ring Amount", range: 0.0...1.0, step: 0.1, value: 0.0),
            SliderInfo(name: "Ring Size", range: 0.0...1.0, step: 0.1, value: 0.1),
            SliderInfo(name: "Softness", range: 0.0...1.0, step: 0.1, value: 0.5)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIBokehBlur") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputRadiusKey)
            filter.setValue(effect.params[1], forKey: "inputRingAmount")
            filter.setValue(effect.params[2], forKey: "inputRingSize")
            filter.setValue(effect.params[3], forKey: "inputSoftness")
            return filter
        }
    )

    static let gaussianBlur = MarkonEffect(
        id: "CIFilter_GaussianBlur",
        name: "Gaussian Blur",
        sliders: [
            SliderInfo(name: "Radius", range: 0.0...100.0, step: 5.0, value: 10.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputRadiusKey)
            return filter
        }
    )

    static let morphologyMaximum = MarkonEffect(
        id: "CIFilter_MorphologyMaximum",
        name: "Morphology Maximum",
        sliders: [
            SliderInfo(name: "Radius", range: 1.0...20.0, step: 1.0, value: 5.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIMorphologyMaximum") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputRadiusKey)
            return filter
        }
    )

    static let photoEffectTonal = MarkonEffect(
        id: "CIFilter_PhotoEffectTonal",
        name: "Photo Effect Tonal",
        sliders: [],
        cifilterProvider: { _ in
            return CIFilter(name: "CIPhotoEffectTonal")
        }
    )

    static let colorPosterize = MarkonEffect(
        id: "CIFilter_ColorPosterize",
        name: "Color Posterize",
        sliders: [
            SliderInfo(name: "Levels", range: 1.0...30.0, step: 1.0, value: 6.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIColorPosterize") else { return nil }
            filter.setValue(effect.params[0], forKey: "inputLevels")
            return filter
        }
    )

    //not working
//    static let circleSplashDistortion = MarkonEffect(
//        id: "CIFilter_CircleSplashDistortion",
//        name: "Circle Splash Distortion",
//        sliders: [
//            SliderInfo(name: "Radius", range: 1.0...500.0, step: 10.0, value: 150.0)
//        ],
//        cifilterProvider: { effect in
//            let filter = CIFilter.circleSplashDistortion()
//            filter.center = CGPoint(x: 50.0, y: 50.0)
//            filter.radius = effect.params[0]
//            return filter
//        }
//    )

//    static let droste = MarkonEffect(
//        id: "CIFilter_Droste",
//        name: "Droste",
//        sliders: [
//            SliderInfo(name: "Strands", range: 0.0...10.0, step: 1.0, value: 1.0),
//            SliderInfo(name: "Periodicity", range: 0.0...10.0, step: 0.1, value: 1.0),
//            SliderInfo(name: "Rotation", range: 0.0...6.28319, step: 0.1, value: 0.0),
//            SliderInfo(name: "Zoom", range: 0.0...10.0, step: 0.1, value: 1.0)
//        ],
//        cifilterProvider: { effect in
//            guard let filter = CIFilter(name: "CIDroste") else { return nil }
//            filter.setValue(effect.params[0], forKey: "inputStrands")
//            filter.setValue(effect.params[1], forKey: "inputPeriodicity")
//            filter.setValue(effect.params[2], forKey: "inputRotation")
//            filter.setValue(effect.params[3], forKey: "inputZoom")
//            return filter
//        }
//    )

    
    static let glassDistortion = MarkonEffect(
        id: "CIFilter_GlassDistortion",
        name: "Glass Distortion",
        sliders: [
            SliderInfo(name: "Scale", range: 100.0...800.0, step: 50.0, value: 200.0)
        ],
        cifilterProvider: { effect in
            let filter = CIFilter.glassDistortion()
            filter.scale = effect.params[0]
            filter.center = CGPoint(x: 0.5, y: 0.5)
            if let pi = PlatformImage(named: "glass_texture"){
                let textureImage = CIImage(platformImage: pi)
                filter.textureImage = textureImage
            }
            return filter
        }
    )

    static let circularScreen = MarkonEffect(
        id: "CIFilter_CircularScreen",
        name: "Circular Screen",
        sliders: [
            SliderInfo(name: "Width", range: 1.0...50.0, step: 1.0, value: 6.0),
            SliderInfo(name: "Sharpness", range: 0.0...1.0, step: 0.1, value: 0.7)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CICircularScreen") else { return nil }
            filter.setValue(effect.params[0], forKey: "inputWidth")
            filter.setValue(effect.params[1], forKey: "inputSharpness")
            return filter
        }
    )

    static let cmykHalftone = MarkonEffect(
        id: "CIFilter_CMYKHalftone",
        name: "CMYK Halftone",
        sliders: [
            SliderInfo(name: "Width", range: 1.0...50.0, step: 1.0, value: 6.0),
            SliderInfo(name: "Angle", range: 0.0...6.28319, step: 0.1, value: 0.0),
            SliderInfo(name: "Sharpness", range: 0.0...1.0, step: 0.1, value: 0.7),
            SliderInfo(name: "GCR", range: 0.0...1.0, step: 0.1, value: 1.0),
            SliderInfo(name: "UCR", range: 0.0...1.0, step: 0.1, value: 0.5)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CICMYKHalftone") else { return nil }
            filter.setValue(effect.params[0], forKey: "inputWidth")
            filter.setValue(effect.params[1], forKey: "inputAngle")
            filter.setValue(effect.params[2], forKey: "inputSharpness")
            filter.setValue(effect.params[3], forKey: "inputGCR")
            filter.setValue(effect.params[4], forKey: "inputUCR")
            return filter
        }
    )

    static let dotScreen = MarkonEffect(
        id: "CIFilter_DotScreen",
        name: "Dot Screen",
        sliders: [
            SliderInfo(name: "Angle", range: 0.0...6.28319, step: 0.1, value: 0.0),
            SliderInfo(name: "Width", range: 1.0...50.0, step: 1.0, value: 6.0),
            SliderInfo(name: "Sharpness", range: 0.0...1.0, step: 0.1, value: 0.7)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIDotScreen") else { return nil }
            filter.setValue(effect.params[0], forKey: "inputAngle")
            filter.setValue(effect.params[1], forKey: "inputWidth")
            filter.setValue(effect.params[2], forKey: "inputSharpness")
            return filter
        }
    )

    static let hatchedScreen = MarkonEffect(
        id: "CIFilter_HatchedScreen",
        name: "Hatched Screen",
        sliders: [
            SliderInfo(name: "Angle", range: 0.0...6.28319, step: 0.1, value: 0.0),
            SliderInfo(name: "Width", range: 1.0...50.0, step: 1.0, value: 6.0),
            SliderInfo(name: "Sharpness", range: 0.0...1.0, step: 0.1, value: 0.7)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIHatchedScreen") else { return nil }
            filter.setValue(effect.params[0], forKey: "inputAngle")
            filter.setValue(effect.params[1], forKey: "inputWidth")
            filter.setValue(effect.params[2], forKey: "inputSharpness")
            return filter
        }
    )

    static let lineScreen = MarkonEffect(
        id: "CIFilter_LineScreen",
        name: "Line Screen",
        sliders: [
            SliderInfo(name: "Angle", range: 0.0...6.28319, step: 0.1, value: 0.0),
            SliderInfo(name: "Width", range: 1.0...50.0, step: 1.0, value: 6.0),
            SliderInfo(name: "Sharpness", range: 0.0...1.0, step: 0.1, value: 0.7)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CILineScreen") else { return nil }
            filter.setValue(effect.params[0], forKey: "inputAngle")
            filter.setValue(effect.params[1], forKey: "inputWidth")
            filter.setValue(effect.params[2], forKey: "inputSharpness")
            return filter
        }
    )

    
    static let cannyEdgeDetector = MarkonEffect(
        id: "CIFilter_CannyEdgeDetector",
        name: "Canny Edge Detector",
        sliders: [
            SliderInfo(name: "Gaussian Sigma", range: 0.0...10.0, step: 0.1, value: 1.6),
            SliderInfo(name: "Threshold Low", range: 0.0...1.0, step: 0.01, value: 0.02),
            SliderInfo(name: "Threshold High", range: 0.0...1.0, step: 0.01, value: 0.05),
            SliderInfo(name: "Hysteresis Passes", range: 0.0...20.0, step: 1.0, value: 1.0)
            // Optionally, you can include a toggle for "Perceptual" if your UI supports it
        ],
        cifilterProvider: { effect in
            let filter = CIFilter.cannyEdgeDetector()
            filter.gaussianSigma = effect.params[0]
            filter.thresholdLow = effect.params[1]
            filter.thresholdHigh = effect.params[2]
            filter.hysteresisPasses = Int(effect.params[3])
            filter.perceptual = false // Set to true if needed, or expose via UI
            return filter
        }
    )
    

    static let edges = MarkonEffect(
        id: "CIFilter_Edges",
        name: "Edges",
        sliders: [
            SliderInfo(name: "Intensity", range: 0.0...10.0, step: 0.5, value: 1.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIEdges") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputIntensityKey)
            return filter
        }
    )

    static let edgeWork = MarkonEffect(
        id: "CIFilter_EdgeWork",
        name: "Edge Work",
        sliders: [
            SliderInfo(name: "Radius", range: 0.0...10.0, step: 1.0, value: 3.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIEdgeWork") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputRadiusKey)
            return filter
        }
    )

    static let gloom = MarkonEffect(
        id: "CIFilter_Gloom",
        name: "Gloom",
        sliders: [
            SliderInfo(name: "Radius", range: 0.0...20.0, step: 1.0, value: 10.0),
            SliderInfo(name: "Intensity", range: 0.0...1.0, step: 0.1, value: 0.5)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIGloom") else { return nil }
            filter.setValue(effect.params[0], forKey: kCIInputRadiusKey)
            filter.setValue(effect.params[1], forKey: kCIInputIntensityKey)
            return filter
        }
    )

    static let gaborGradients = MarkonEffect(
        id: "CIFilter_GaborGradients",
        name: "Gabor Gradients",
        sliders: [],
        cifilterProvider: { _ in
            return CIFilter(name: "CIGaborGradients")
        }
    )

    static let hexagonalPixellate = MarkonEffect(
        id: "CIFilter_HexagonalPixellate",
        name: "Hexagonal Pixellate",
        sliders: [
            SliderInfo(name: "Scale", range: 1.0...100.0, step: 5.0, value: 8.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CIHexagonalPixellate") else { return nil }
            filter.setValue(effect.params[0], forKey: "inputScale")
            return filter
        }
    )

    static let lineOverlay = MarkonEffect(
        id: "CIFilter_LineOverlay",
        name: "Line Overlay",
        sliders: [
            SliderInfo(name: "NR Noise Level", range: 0.0...0.1, step: 0.01, value: 0.07),
            SliderInfo(name: "NR Sharpness", range: 0.0...1.0, step: 0.1, value: 0.71),
            SliderInfo(name: "Edge Intensity", range: 0.0...5.0, step: 0.1, value: 1.0),
            SliderInfo(name: "Threshold", range: 0.0...1.0, step: 0.1, value: 0.1),
            SliderInfo(name: "Contrast", range: 0.0...100.0, step: 5.0, value: 50.0)
        ],
        cifilterProvider: { effect in
            guard let filter = CIFilter(name: "CILineOverlay") else { return nil }
            filter.setValue(effect.params[0], forKey: "inputNRNoiseLevel")
            filter.setValue(effect.params[1], forKey: "inputNRSharpness")
            filter.setValue(effect.params[2], forKey: "inputEdgeIntensity")
            filter.setValue(effect.params[3], forKey: "inputThreshold")
            filter.setValue(effect.params[4], forKey: "inputContrast")
            return filter
        }
    )

    static let sobelGradients = MarkonEffect(
        id: "CIFilter_SobelGradients",
        name: "Sobel Gradients",
        sliders: [],
        cifilterProvider: { _ in
            return CIFilter(name: "CISobelGradients")
        }
    )

    static let xRay = MarkonEffect(
        id: "CIFilter_XRay",
        name: "X-Ray",
        sliders: [],
        cifilterProvider: { _ in
            return CIFilter.xRay()
        }
    )
    
    static let scratchyFilm = MarkonEffect(
        id: "CIFilter_ScratchyFilm",
        name: "Scratchy Film",
        sliders: [
            //SliderInfo(name: "Grain Blur Radius", range: 0.0...10.0, step: 0.5, value: 2.0),
            //SliderInfo(name: "Vignette Intensity", range: 0.0...2.0, step: 0.1, value: 1.0),
            //SliderInfo(name: "Vignette Radius", range: 0.0...5.0, step: 0.1, value: 2.0)
        ],
        cifilterProvider: { effect in
            return ScratchyFilmFilter()
        }
    )
}
