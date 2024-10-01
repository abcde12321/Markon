//
//  Untitled.swift
//  Markon
//
//  Created by Fan Yang on 19/09/2024.
//

import SwiftUI


#if os(macOS)
import AppKit

public typealias PlatformImage = NSImage

extension Image {
  public init(platformImage: PlatformImage) {
    self.init(nsImage: platformImage)
  }
}

#elseif os(iOS)
import UIKit

public typealias PlatformImage = UIImage

extension UIImage{
    public convenience init?(contentsOf url: URL) {
        if let data = try? Data(contentsOf: url) {
            self.init(data: data)
        } else {
            return nil
        }
    }
}

extension Image {
  public init(platformImage: PlatformImage) {
    self.init(uiImage: platformImage)
  }
}

#endif


extension PlatformImage {
    /// Converts PlatformImage to JPEG Data
    #if os(macOS)
    func jpegData(compressionQuality: CGFloat = 1.0) -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
    #endif
}



extension PlatformImage : @unchecked Sendable {}


extension CIImage {
    convenience init?(platformImage: PlatformImage) {
        #if os(iOS)
        self.init(image: platformImage)
        #elseif os(macOS)
        guard let data = platformImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: data),
              let cgImage = bitmapImage.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
        #endif
    }
    
    /// Downscale the CIImage to the specified target size while maintaining the aspect ratio.
    func downscaled(to targetSize: CGSize) -> CIImage? {
        let scaleX = targetSize.width / self.extent.width
        let scaleY = targetSize.height / self.extent.height
        let scale = min(scaleX, scaleY) // To maintain aspect ratio
        
        let transform = CIFilter(name: "CILanczosScaleTransform")!
        transform.setValue(self, forKey: kCIInputImageKey)
        transform.setValue(scale, forKey: kCIInputScaleKey)
        transform.setValue(1.0, forKey: kCIInputAspectRatioKey) // Preserve aspect ratio
        
        return transform.outputImage
    }
}
