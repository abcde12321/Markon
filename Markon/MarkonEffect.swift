//
//  MarkonEffect.swift
//  Markon
//
//  Created by Fan Yang on 13/09/2024.
//

import Foundation
import CoreImage


struct MarkonEffect: Identifiable, Hashable{

    let id: String
    let name: String
    var sliders: [SliderInfo]
    let cifilterProvider: (MarkonEffect) -> CIFilter?
    
    var params: [Float] {
        return sliders.map { Float($0.value) }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var description: String {
        return "MarkonEffect(id: \(id), name: \(name), params: \(params))"
    }
    
    static func == (lhs: MarkonEffect, rhs: MarkonEffect) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Computed property to get the CIFilter using the provider
    var cifilter: CIFilter? {
        return cifilterProvider(self)
    }
}

struct SliderInfo {
    let name: String
    let range: ClosedRange<Double>
    let step: Double
    var value: Double
}
