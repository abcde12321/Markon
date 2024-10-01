//
//  ContentView.swift
//  Markon
//
//  Created by Fan Yang on 08/08/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @StateObject var imageProcessor = CIFilterProcessor.shared
    
    @State private var isDraggingOver = false // Track when an image is being dragged over the area
    
    var body: some View {
        ZStack {
            // Drop area that covers the entire window
            Rectangle()
                .fill(Color.clear)
                .onDrop(of: ["public.image"], isTargeted: $isDraggingOver, perform: handleDrop)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Show drag and drop instructions only when no image is present
            if imageProcessor.originalImage == nil {
                VStack(spacing: 30) {
                    Rectangle()
                        .fill(Color.clear)
                        .border(isDraggingOver ? Color.green : Color.gray, width: 4)
                        .overlay(
                            Text("Drag & Drop Image Here")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                        .padding()
                    
                    // Button to read from the pasteboard
                    Button(action: {
                        readImageFromPasteboard()
                    }) {
                        Text("Paste Image")
                    }
                    .padding()
                }
            } else {
                // Show the dropped image
                PhotoEditingPreview()
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
    
    private func readImageFromPasteboard() {
        #if os(iOS)
        let pasteboard = UIPasteboard.general
        
        // Check if an image is available directly
        if let image = pasteboard.image {
            imageProcessor.originalImage = image
        } else {
            // Iterate over items in the pasteboard
            for item in pasteboard.items {
                if let data = item[UTType.image.identifier] as? Data,
                   let image = UIImage(data: data) {
                    imageProcessor.originalImage = image
                    return
                }
            }
            print("No image found in the pasteboard.")
        }
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        
        // Use UTType.image to get data for any image type
        if let data = pasteboard.data(forType: NSPasteboard.PasteboardType(UTType.image.identifier)),
           let image = NSImage(data: data) {
            imageProcessor.originalImage = image
        } else if let data = pasteboard.data(forType: .fileURL),
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  let image = NSImage(contentsOf: url) {
            imageProcessor.originalImage = image
        } else {
            print("No image found in the pasteboard.")
        }
        #endif
    }
}

#Preview {
    ContentView()
}
