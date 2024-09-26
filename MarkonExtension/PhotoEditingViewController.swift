//
//  PhotoEditingViewController.swift
//  MarkonExtension
//
//  Created by Fan Yang on 08/08/2024.
//
#if os(macOS)
import Cocoa
#endif

import Photos
import PhotosUI
import SwiftUI


let formatIdentifier = "Fan.Markon.MarkonExtension"

#if os(macOS)
typealias PlatformViewController = NSViewController
typealias HostingController = NSHostingController
#elseif os(iOS)
typealias PlatformViewController = UIViewController
typealias HostingController = UIHostingController
#endif


class PhotoEditingViewController: PlatformViewController, PHContentEditingController {
    
    var input: PHContentEditingInput?
    
    //var originalImage: NSImage?
    //var editedImage: NSImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: PlatformImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput

        
        if let displayImage = contentEditingInput.displaySizeImage  {
            print("startContentEditing: load displayImage")
            GPUImageProcessor.shared.originalImage = displayImage
        }else{
            print("startContentEditing: load full size Image")
            
            #if os(macOS)
            if let sourceImageURL = contentEditingInput.fullSizeImageURL,
               let image = NSImage(contentsOf: sourceImageURL) {
                GPUImageProcessor.shared.originalImage = image
            } else {
                print("startContentEditing: failed to load full size Image!")
            }
            #elseif os(iOS)
            if let sourceImageURL = contentEditingInput.fullSizeImageURL,
               let imageData = try? Data(contentsOf: sourceImageURL),
               let image = UIImage(data: imageData) {
                GPUImageProcessor.shared.originalImage = image
            } else {
                print("startContentEditing: failed to load full size Image!")
            }
            #endif
        }
        
            
        // Show the PhotoEditingPreview
        DispatchQueue.main.async {
            let previewView = PhotoEditingPreview()
            let hostingController = HostingController(rootView: previewView)
            self.addChild(hostingController)
            hostingController.view.frame = self.view.bounds
            self.view.addSubview(hostingController.view)
        }
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        print("finishContentEditing")
        guard let input = self.input,
              let editedImage = GPUImageProcessor.shared.processedImage else {
                  completionHandler(nil)
                  print("finishContentEditing failed, no processed image.")
                  return
              }
        
        // Create editing output from the editing input.
        let output = PHContentEditingOutput(contentEditingInput: input)
        
        #if os(macOS)
        if let imageData = editedImage.tiffRepresentation,
           let bitmapImageRep = NSBitmapImageRep(data: imageData),
           let jpegData = bitmapImageRep.representation(using: .jpeg, properties: [:]) {
            
            do {
                try jpegData.write(to: output.renderedContentURL, options: [.atomic])
                output.adjustmentData = PHAdjustmentData(formatIdentifier: formatIdentifier, formatVersion: "1.0", data: Data(count: 10))
                completionHandler(output)
            } catch {
                print("finishContentEditing Error writing image data: \(error)")
                completionHandler(nil)
            }
        } else {
            print("finishContentEditing Error: Failed to create JPEG data.")
            completionHandler(nil)
        }
        #elseif os(iOS)
        if let jpegData = editedImage.jpegData(compressionQuality: 1.0) {
            do {
                try jpegData.write(to: output.renderedContentURL, options: [.atomic])
                output.adjustmentData = PHAdjustmentData(formatIdentifier: formatIdentifier, formatVersion: "1.0", data: Data(count: 10))
                completionHandler(output)
            } catch {
                print("finishContentEditing Error writing image data: \(error)")
                completionHandler(nil)
            }
        } else {
            print("finishContentEditing Error: Failed to create JPEG data.")
            completionHandler(nil)
        }
        #endif
        
        GPUImageProcessor.shared.processedImage = nil
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }
    
    func requestImage(for asset: PHAsset, targetSize: CGSize, completion: @escaping (PlatformImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: options
        ) { (image, info) in
            completion(image)
        }
    }

}
