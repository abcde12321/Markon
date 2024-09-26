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


extension PlatformImage : @unchecked Sendable {}
