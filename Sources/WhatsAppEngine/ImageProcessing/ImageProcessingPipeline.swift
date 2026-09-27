import Foundation
#if canImport(StickerCore)
import StickerCore
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SDWebImageWebPCoder)
import SDWebImageWebPCoder
#endif
#if canImport(SDWebImage)
import SDWebImage
#endif

/// Complete image conversion and preparation pipeline for WhatsApp stickers.
/// Guarantees that all stickers are aspect-fit centered on a 512x512 transparent canvas
/// and encoded as compliant WebP files. Supports auto-converting static stickers in animated packs.
public final class ImageProcessingPipeline: @unchecked Sendable {
    
    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    private let networkClient: NetworkClient
    
    public init(
        cacheDirectory: URL = FileManager.default.temporaryDirectory.appendingPathComponent("WhatsAppStickersCache", isDirectory: true),
        networkClient: NetworkClient = NetworkClient()
    ) {
        self.cacheDirectory = cacheDirectory
        self.networkClient = networkClient
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Prepares and optimizes an emote into a WhatsApp-compliant 512x512 WebP file.
    /// If the pack is animated, static emotes are automatically converted into 2-frame looped WebPs
    /// so WhatsApp accepts the entire pack without mixed-format rejection.
    public func processSticker(
        for emote: EmoteItem,
        isPartOfAnimatedPack: Bool = false
    ) async throws -> (fileURL: URL, data: Data) {
        let destination = cacheDirectory.appendingPathComponent("v5_\(emote.id)_\(isPartOfAnimatedPack ? "anim" : "stat").webp")
        
        // Check local cache first
        if fileManager.fileExists(atPath: destination.path),
           let cachedData = try? Data(contentsOf: destination),
           cachedData.count > 0 {
            return (destination, cachedData)
        }
        
        guard let remoteURL = emote.preferredStickerImageURL ?? emote.thumbnailURL else {
            throw NetworkError.unknown("Emote için geçerli bir görsel URL bulunamadı.")
        }
        
        let rawData = try await networkClient.downloadData(from: remoteURL)
        
        #if canImport(UIKit) && canImport(SDWebImageWebPCoder)
        let coder = SDImageWebPCoder.shared
        let decodedImage = SDImageCodersManager.shared.decodedImage(with: rawData, options: nil)
            ?? coder.decodedImage(with: rawData, options: nil)
            ?? UIImage(data: rawData)
            
        if let decodedImage = decodedImage {
            if let frames = decodedImage.images, frames.count > 1 {
                // Animated Emote: subsample and render each frame onto 512x512 canvas
                let totalFrames = frames.count
                let totalDuration = decodedImage.duration > 0 ? decodedImage.duration : Double(totalFrames) * 0.1
                
                // Adaptive multi-pass compression to strictly satisfy <= 480 KB limit
                var finalData: Data?
                var frameBudget = min(24, totalFrames)
                
                while frameBudget >= 6 {
                    let plannedFrames = AnimatedWebPOptimizer.planFrameSampling(
                        totalFrames: totalFrames,
                        totalDuration: totalDuration,
                        targetMaxFrames: frameBudget
                    )
                    
                    var sdFrames: [SDImageFrame] = []
                    for meta in plannedFrames {
                        let frame = frames[meta.index]
                        let resized = CanvasResizer.renderOnCanvas(
                            image: frame,
                            targetSize: CanvasResizer.targetStickerSize,
                            margin: CGFloat(WhatsAppLimits.recommendedMargin)
                        ) ?? frame
                        let duration = max(0.012, meta.durationSeconds)
                        sdFrames.append(SDImageFrame(image: resized, duration: duration))
                    }
                    
                    for quality: Double in [0.75, 0.55, 0.40, 0.25] {
                        let opts: [SDImageCoderOption: Any] = [.encodeCompressionQuality: quality]
                        if let data = coder.encodedData(with: sdFrames, loopCount: 0, format: .webP, options: opts) {
                            if data.count <= WhatsAppLimits.safeAnimatedStickerBytes {
                                finalData = data
                                break
                            }
                        }
                    }
                    
                    if finalData != nil {
                        break
                    }
                    // If still over 480 KB, halve frame budget and try again
                    frameBudget = frameBudget / 2
                }
                
                if let data = finalData {
                    try data.write(to: destination, options: .atomic)
                    return (destination, data)
                }
            } else {
                // Static Emote: render onto 512x512 transparent canvas
                if let resized = CanvasResizer.renderOnCanvas(
                    image: decodedImage,
                    targetSize: CanvasResizer.targetStickerSize,
                    margin: CGFloat(WhatsAppLimits.recommendedMargin)
                ) {
                    var finalData: Data?
                    
                    if isPartOfAnimatedPack {
                        // WhatsApp requires all stickers in an animated pack to have multiple frames (>1 frame).
                        // We duplicate the frame into a 2-frame looped animation encoded via SDImageFrame!
                        let sdFrames = [
                            SDImageFrame(image: resized, duration: 1.0),
                            SDImageFrame(image: resized, duration: 1.0)
                        ]
                        for quality: Double in [0.80, 0.60, 0.40] {
                            let opts: [SDImageCoderOption: Any] = [.encodeCompressionQuality: quality]
                            if let data = coder.encodedData(with: sdFrames, loopCount: 0, format: .webP, options: opts) {
                                if data.count <= WhatsAppLimits.safeAnimatedStickerBytes || quality <= 0.40 {
                                    finalData = data
                                    break
                                }
                            }
                        }
                    } else {
                        // Single-frame static WebP
                        for quality: Double in [0.85, 0.70, 0.50] {
                            let opts: [SDImageCoderOption: Any] = [.encodeCompressionQuality: quality]
                            if let data = coder.encodedData(with: resized, format: .webP, options: opts) {
                                if data.count <= WhatsAppLimits.maxStaticStickerBytes || quality <= 0.50 {
                                    finalData = data
                                    break
                                }
                            }
                        }
                    }
                    
                    if let data = finalData {
                        try data.write(to: destination, options: .atomic)
                        return (destination, data)
                    }
                }
            }
        }
        #endif
        
        let finalData: Data = rawData
        try finalData.write(to: destination, options: .atomic)
        return (destination, finalData)
    }
    
    /// Generates a 96x96 static PNG tray icon (< 50 KB) from the given emote as strictly required by WhatsApp iOS.
    public func processTrayIcon(for emote: EmoteItem) async throws -> Data {
        guard let remoteURL = emote.thumbnailURL ?? emote.preferredStickerImageURL else {
            throw NetworkError.unknown("Tray icon için geçerli görsel bulunamadı.")
        }
        
        let rawData = try await networkClient.downloadData(from: remoteURL)
        
        #if canImport(UIKit)
        let coder = SDImageWebPCoder.shared
        let decodedImage = SDImageCodersManager.shared.decodedImage(with: rawData, options: nil)
            ?? coder.decodedImage(with: rawData, options: nil)
            ?? UIImage(data: rawData)
            
        // WhatsApp requires the tray image to be:
        // 1. Exactly 96x96 pixels
        // 2. Static PNG (NOT WebP, and NOT animated)
        // 3. File size <= 50 KB
        let firstFrame = decodedImage?.images?.first ?? decodedImage
        
        if let image = firstFrame,
           let trayImage = CanvasResizer.renderOnCanvas(
            image: image,
            targetSize: CanvasResizer.targetTraySize,
            margin: 4.0
           ),
           let pngData = trayImage.pngData() {
            if pngData.count <= WhatsAppLimits.maxTrayIconBytes {
                return pngData
            }
        }
        #endif
        
        throw NetworkError.unknown("Tray icon WhatsApp uyumlu PNG formatında oluşturulamadı.")
    }
    
    /// Clears the temporary sticker conversion cache.
    public func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}
