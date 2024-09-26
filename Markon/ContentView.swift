//
//  ContentView.swift
//  Markon
//
//  Created by Fan Yang on 08/08/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var imageProcessor = GPUImageProcessor.shared
    
    @State private var isDraggingOver = false // Track when an image is being dragged over the area
    
    var body: some View {
        ZStack {
            // Drop area at the bottom
            RoundedRectangle(cornerRadius: 10)
                .stroke(isDraggingOver ? Color.green : Color.gray, lineWidth: 4)
                .frame(width: 300, height: 200)
                .overlay(
                    Text("Drag & Drop Image Here")
                        .font(.title2)
                        .foregroundColor(.gray)
                )
                .onDrop(of: ["public.image"], isTargeted: $isDraggingOver, perform: handleDrop)
                .padding()
            
            // Show the dropped image on top if it exists
            if imageProcessor.originalImage != nil {
                VStack {
                    PhotoEditingPreview()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Handle the drop of the image and check for valid image types
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        print("handleDrop:", providers)
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.image") {
                print("handleDrop: provider.hasItemConformingToTypeIdentifier")
                provider.loadItem(forTypeIdentifier: "public.image", options: nil) { item, error in
                    if let error = error {
                        print("handleDrop: Error loading item: \(error.localizedDescription)")
                        return
                    }
                    
                    // Try to load the image as Data first
                    if let data = item as? Data, let image = PlatformImage(data: data) {
                        print("handleDrop: converting data to image")
                        DispatchQueue.main.async {
                            //self.droppedImage = image  // Set the dropped image
                            imageProcessor.originalImage = image
                        }
                    }
                    // If the item is a URL (file), load the image from the file URL
                    else if let url = item as? URL {
                        print("handleDrop: received a file URL")
                        if let image = PlatformImage(contentsOf: url) {
                            DispatchQueue.main.async {
                                //self.droppedImage = image  // Set the dropped image
                                imageProcessor.originalImage = image
                            }
                        } else {
                            print("handleDrop: failed to load image from URL")
                        }
                    } else {
                        print("handleDrop: unhandled item type")
                    }
                }
                return true
            }
        }
        return false
    }
}

#Preview {
    ContentView()
}
