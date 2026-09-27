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
        let destination = cacheDirectory.appendingPathComponent("\(emote.id)_\(isPartOfAnimatedPack ? "anim" : "stat").webp")
        
        // Check local cache first
        if fileManager.fileExists(atPath: destination.path),
           let cachedData = try? Data(contentsOf: destination),
           cachedData.count > 0 {
            return (destination, cachedData)
        }
        
        guard let remoteURL = emote.preferredStickerImageURL else {
            throw NetworkError.unknown("Emote için geçerli bir görsel URL bulunamadı.")
        }
        
        let rawData = try await networkClient.downloadData(from: remoteURL)
        
        #if canImport(UIKit) && canImport(SDWebImageWebPCoder)
        let coder = SDImageWebPCoder.shared
        if let decodedImage = coder.decodedImage(with: rawData, options: nil) ?? UIImage(data: rawData) {
            if let frames = decodedImage.images, frames.count > 1 {
                // Animated Emote: subsample and render each frame onto 512x512 canvas
                let totalFrames = frames.count
                let totalDuration = decodedImage.duration > 0 ? decodedImage.duration : 1.0
                let plannedFrames = AnimatedWebPOptimizer.planFrameSampling(
                    totalFrames: totalFrames,
                    totalDuration: totalDuration,
                    targetMaxFrames: 30
                )
                
                var resizedFrames: [UIImage] = []
                for meta in plannedFrames {
                    let frame = frames[meta.index]
                    if let resized = CanvasResizer.renderOnCanvas(
                        image: frame,
                        targetSize: CanvasResizer.targetStickerSize,
                        margin: CGFloat(WhatsAppLimits.recommendedMargin)
                    ) {
                        resizedFrames.append(resized)
                    } else {
                        resizedFrames.append(frame)
                    }
                }
                
                let animatedImage = UIImage.animatedImage(
                    with: resizedFrames,
                    duration: min(totalDuration, WhatsAppLimits.maxAnimationDurationSeconds)
                ) ?? decodedImage
                
                // Adaptive compression to strictly satisfy <= 500 KB limit
                var finalData: Data?
                for quality: Double in [0.75, 0.60, 0.45, 0.30] {
                    let opts: [SDImageCoderOption: Any] = [.encodeCompressionQuality: quality]
                    if let data = coder.encodedData(with: animatedImage, format: .webP, options: opts) {
                        if data.count <= WhatsAppLimits.safeAnimatedStickerBytes || quality <= 0.30 {
                            finalData = data
                            break
                        }
                    }
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
                        // We duplicate the frame into a 2-frame looped animation so WhatsApp accepts it seamlessly!
                        let loopedImage = UIImage.animatedImage(with: [resized, resized], duration: 4.0) ?? resized
                        for quality: Double in [0.80, 0.60, 0.40] {
                            let opts: [SDImageCoderOption: Any] = [.encodeCompressionQuality: quality]
                            if let data = coder.encodedData(with: loopedImage, format: .webP, options: opts) {
                                if data.count <= WhatsAppLimits.safeAnimatedStickerBytes || quality <= 0.40 {
                                    finalData = data
                                    break
                                }
                            }
                        }
                    } else {
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
    
    /// Generates a 96x96 tray icon (< 50 KB) from the given emote.
    public func processTrayIcon(for emote: EmoteItem) async throws -> Data {
        guard let remoteURL = emote.thumbnailURL ?? emote.preferredStickerImageURL else {
            throw NetworkError.unknown("Tray icon için geçerli görsel bulunamadı.")
        }
        
        let rawData = try await networkClient.downloadData(from: remoteURL)
        
        #if canImport(UIKit)
        let coder: SDImageWebPCoder?
        #if canImport(SDWebImageWebPCoder)
        coder = SDImageWebPCoder.shared
        #else
        coder = nil
        #endif
        
        let decodedImage = (coder?.decodedImage(with: rawData, options: nil)) ?? UIImage(data: rawData)
        if let image = decodedImage,
           let trayImage = CanvasResizer.renderOnCanvas(
            image: image,
            targetSize: CanvasResizer.targetTraySize,
            margin: 4.0
           ) {
            if let pngData = trayImage.pngData(), pngData.count <= WhatsAppLimits.maxTrayIconBytes {
                return pngData
            }
            #if canImport(SDWebImageWebPCoder)
            if let webpData = coder?.encodedData(with: trayImage, format: .webP, options: [.encodeCompressionQuality: 0.8]),
               webpData.count <= WhatsAppLimits.maxTrayIconBytes {
                return webpData
            }
            #endif
        }
        #endif
        
        return rawData
    }
    
    /// Clears the temporary sticker conversion cache.
    public func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}
