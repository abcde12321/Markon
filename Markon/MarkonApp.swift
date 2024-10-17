//
//  MarkonApp.swift
//  Markon
//
//  Created by Fan Yang on 08/08/2024.
//

import SwiftUI

@main
struct MarkonApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    let processor = CIFilterProcessor.shared
                    //image from the url
                    processor.originalImage = PlatformImage(contentsOf: url)
                }
        }
    }
}
