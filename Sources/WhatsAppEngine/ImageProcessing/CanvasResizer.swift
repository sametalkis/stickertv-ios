import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif
#if canImport(UIKit)
import UIKit
#endif

/// Handles aspect-fit geometry and coordinate calculations for the 512x512 transparent canvas.
public struct CanvasResizer: Sendable {
    
    /// Target dimensions for stickers.
    public static let targetStickerSize = CGSize(width: 512, height: 512)
    
    /// Target dimensions for the tray icon.
    public static let targetTraySize = CGSize(width: 96, height: 96)
    
    /// Calculates the aspect-fit destination rect inside the target canvas with optional padding.
    public static func aspectFitRect(
        originalSize: CGSize,
        targetSize: CGSize,
        margin: CGFloat = 16.0
    ) -> CGRect {
        guard originalSize.width > 0, originalSize.height > 0 else {
            return CGRect(origin: .zero, size: targetSize)
        }
        
        let availableWidth = max(1, targetSize.width - (margin * 2))
        let availableHeight = max(1, targetSize.height - (margin * 2))
        
        let widthRatio = availableWidth / originalSize.width
        let heightRatio = availableHeight / originalSize.height
        let scale = min(widthRatio, heightRatio)
        
        let scaledWidth = originalSize.width * scale
        let scaledHeight = originalSize.height * scale
        
        let originX = (targetSize.width - scaledWidth) / 2.0
        let originY = (targetSize.height - scaledHeight) / 2.0
        
        return CGRect(
            x: originX.rounded(),
            y: originY.rounded(),
            width: scaledWidth.rounded(),
            height: scaledHeight.rounded()
        )
    }
    
    #if canImport(UIKit)
    /// Renders an input UIImage onto a 512x512 transparent background respecting margins.
    public static func renderOnCanvas(
        image: UIImage,
        targetSize: CGSize = targetStickerSize,
        margin: CGFloat = 16.0
    ) -> UIImage? {
        let drawRect = aspectFitRect(
            originalSize: image.size,
            targetSize: targetSize,
            margin: margin
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // 1x pixel-to-pixel (512x512 exact)
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            image.draw(in: drawRect)
        }
    }
    #endif
}
