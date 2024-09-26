//
//  MarkonEffect.swift
//  Markon
//
//  Created by Fan Yang on 13/09/2024.
//

import Foundation


struct MarkonEffect: Identifiable, Hashable{

    let id: String
    let name: String
    var sliders: [SliderInfo]
    
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
}

struct SliderInfo {
    let name: String
    let range: ClosedRange<Double>
    let step: Double
    var value: Double
}
