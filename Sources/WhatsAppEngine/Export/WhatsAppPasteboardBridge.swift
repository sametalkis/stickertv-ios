import Foundation
#if canImport(StickerCore)
import StickerCore
#endif
#if canImport(UIKit)
import UIKit
#endif

public enum WhatsAppExportError: LocalizedError, Sendable {
    case validationFailed([String])
    case whatsAppNotInstalled
    case encodingFailed(String)
    case pasteboardError
    
    public var errorDescription: String? {
        switch self {
        case .validationFailed(let errors):
            return "Paket doğrulanamadı:\n" + errors.joined(separator: "\n")
        case .whatsAppNotInstalled:
            return "Cihazınızda WhatsApp yüklü değil veya çıkartma aktarımı desteklenmiyor."
        case .encodingFailed(let msg):
            return "Paket dışa aktarılırken kodlama hatası oluştu: \(msg)"
        case .pasteboardError:
            return "Pano (Pasteboard) üzerine çıkartma verisi yazılamadı."
        }
    }
}

/// Manages exporting the validated StickerPack to WhatsApp via iOS UIPasteboard and DeepLink URL Scheme.
public final class WhatsAppPasteboardBridge: @unchecked Sendable {
    
    private let pipeline: ImageProcessingPipeline
    
    public init(pipeline: ImageProcessingPipeline = ImageProcessingPipeline()) {
        self.pipeline = pipeline
    }
    
    /// Prepares and sends the sticker pack directly to WhatsApp.
    @MainActor
    public func export(pack: StickerPack) async throws {
        // 1. Pre-flight validation
        let validation = WhatsAppValidationEngine.validate(pack: pack)
        guard validation.isValid else {
            throw WhatsAppExportError.validationFailed(validation.errors)
        }
        
        // 2. Prepare Tray Icon
        guard let trayEmote = pack.effectiveTrayEmote else {
            throw WhatsAppExportError.validationFailed(["Tray icon bulunamadı."])
        }
        let trayData = try await pipeline.processTrayIcon(for: trayEmote)
        let trayBase64 = trayData.base64EncodedString()
        
        // 3. Prepare Stickers
        var stickerPayloads: [WhatsAppStickerPayload] = []
        for sticker in pack.stickers {
            let (_, stickerData) = try await pipeline.processSticker(for: sticker.emote)
            let base64 = stickerData.base64EncodedString()
            
            // Ensure emojis exist, fallback to smart suggestion if empty
            let emojis = sticker.emojis.isEmpty
                ? EmojiSuggester.suggest(for: sticker.emote.name, tags: sticker.emote.tags)
                : sticker.emojis
            
            stickerPayloads.append(
                WhatsAppStickerPayload(
                    imageData: base64,
                    emojis: emojis
                )
            )
        }
        
        // 4. Construct WhatsApp Sticker Pack Payload
        let payload = WhatsAppStickerPackPayload(
            identifier: pack.id.uuidString,
            name: pack.name,
            publisher: pack.publisher,
            trayImageData: trayBase64,
            publisherWebsite: "https://7tv.app",
            privacyPolicyWebsite: "https://7tv.app/privacy",
            licenseAgreementWebsite: "https://7tv.app/terms",
            animatedStickerPack: pack.isAnimatedPack,
            stickers: stickerPayloads
        )
        
        // 5. JSON Encode
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(payload) else {
            throw WhatsAppExportError.encodingFailed("JSON paketi oluşturulamadı.")
        }
        
        #if canImport(UIKit)
        guard let url = URL(string: WhatsAppLimits.urlScheme),
              UIApplication.shared.canOpenURL(url) else {
            throw WhatsAppExportError.whatsAppNotInstalled
        }
        
        // Write to UIPasteboard
        let pasteboard = UIPasteboard.general
        pasteboard.setValue(jsonData, forPasteboardType: WhatsAppLimits.pasteboardType)
        
        // Open WhatsApp via URL scheme
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        #endif
    }
}
