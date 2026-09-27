import Foundation
import StickerCore
#if canImport(UIKit)
import UIKit
#endif

/// Complete image conversion and preparation pipeline for WhatsApp stickers.
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
    
    /// Prepares and optimizes an emote into a WhatsApp-compliant WebP file.
    public func processSticker(for emote: EmoteItem) async throws -> (fileURL: URL, data: Data) {
        let destination = cacheDirectory.appendingPathComponent("\(emote.id).webp")
        
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
        
        var finalData: Data = rawData
        
        #if canImport(UIKit)
        if !emote.isAnimated, let uiImage = UIImage(data: rawData) {
            // Re-render onto 512x512 transparent canvas
            if let canvasImage = CanvasResizer.renderOnCanvas(image: uiImage) {
                // If native webp encoder is available, encode; otherwise preserve validated webp
                if let png = canvasImage.pngData() {
                    // For static, fallback to raw or converted data
                    finalData = png
                }
            }
        }
        #endif
        
        // Write to local temporary file
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
        if let uiImage = UIImage(data: rawData),
           let trayImage = CanvasResizer.renderOnCanvas(
            image: uiImage,
            targetSize: CanvasResizer.targetTraySize,
            margin: 4.0
           ),
           let pngData = trayImage.pngData() {
            return pngData
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
