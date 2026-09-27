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
        var stickersArray: [[String: Any]] = []
        for sticker in pack.stickers {
            let (_, stickerData) = try await pipeline.processSticker(for: sticker.emote)
            let base64 = stickerData.base64EncodedString()
            
            // Ensure emojis exist, fallback to smart suggestion if empty
            let emojis = sticker.emojis.isEmpty
                ? EmojiSuggester.suggest(for: sticker.emote.name, tags: sticker.emote.tags)
                : sticker.emojis
            
            var stickerDict: [String: Any] = [:]
            stickerDict["image_data"] = base64
            stickerDict["emojis"] = emojis
            stickersArray.append(stickerDict)
        }
        
        // 4. Construct WhatsApp Sticker Pack Payload matching official specs
        var json: [String: Any] = [:]
        json["identifier"] = pack.id.uuidString
        json["name"] = pack.name
        json["publisher"] = pack.publisher
        json["tray_image"] = trayBase64
        if pack.isAnimatedPack {
            json["animated_sticker_pack"] = true
        }
        json["stickers"] = stickersArray
        
        // 5. JSON Serialization
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            throw WhatsAppExportError.encodingFailed("JSON paketi oluşturulamadı.")
        }
        
        #if canImport(UIKit)
        guard let url = URL(string: WhatsAppLimits.urlScheme),
              UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!) else {
            throw WhatsAppExportError.whatsAppNotInstalled
        }
        
        // Write to UIPasteboard using official WhatsApp UTI and options
        let pasteboard = UIPasteboard.general
        pasteboard.setItems([[WhatsAppLimits.pasteboardType: jsonData]], options: [
            UIPasteboard.OptionsKey.localOnly: true,
            UIPasteboard.OptionsKey.expirationDate: NSDate(timeIntervalSinceNow: 60)
        ])
        
        // Open WhatsApp via URL scheme
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        #endif
    }
}
