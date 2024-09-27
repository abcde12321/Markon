//
//  CIFilterEffect.swift
//  Markon
//
//  Created by Fan Yang on 27/09/2024.
//

import CoreImage
import SwiftUI

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
        invert
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
}
