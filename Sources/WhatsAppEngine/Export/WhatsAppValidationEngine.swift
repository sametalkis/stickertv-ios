import Foundation
#if canImport(StickerCore)
import StickerCore
#endif

/// Result of WhatsApp sticker pack validation before export.
public struct PackValidationResult: Sendable {
    public let isValid: Bool
    public let errors: [String]
    public let warnings: [String]
    
    public init(isValid: Bool, errors: [String], warnings: [String] = []) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
    }
}

/// Pre-flight validator checking a StickerPack against all official WhatsApp constraints.
public struct WhatsAppValidationEngine: Sendable {
    
    public static func validate(pack: StickerPack) -> PackValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // 1. Pack name validation
        let trimmedName = pack.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errors.append("Paket adı boş olamaz.")
        } else if trimmedName.count > 128 {
            errors.append("Paket adı 128 karakterden uzun olamaz.")
        }
        
        // 2. Publisher name validation
        let trimmedPub = pack.publisher.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPub.isEmpty {
            errors.append("Yayıncı adı boş olamaz.")
        } else if trimmedPub.count > 128 {
            errors.append("Yayıncı adı 128 karakterden uzun olamaz.")
        }
        
        // 3. Sticker count limits
        if pack.stickers.count < WhatsAppLimits.minStickerCount {
            errors.append("WhatsApp için pakette en az \(WhatsAppLimits.minStickerCount) çıkartma olmalıdır (Mevcut: \(pack.stickers.count)).")
        } else if pack.stickers.count > WhatsAppLimits.maxStickerCount {
            errors.append("WhatsApp için pakette en fazla \(WhatsAppLimits.maxStickerCount) çıkartma olabilir (Mevcut: \(pack.stickers.count)).")
        }
        
        // 4. Mixed animated & static check (WhatsApp does not allow mixed packs)
        let animatedCount = pack.stickers.filter { $0.emote.isAnimated }.count
        if animatedCount > 0 && animatedCount < pack.stickers.count {
            errors.append("WhatsApp bir pakette hem hareketli hem statik çıkartmaların bir arada bulunmasına izin vermez (\(animatedCount) hareketli, \(pack.stickers.count - animatedCount) statik). Lütfen paketteki çıkartmaların tamamını hareketli veya tamamını statik yapın.")
        }
        
        // 5. Sticker individual constraints
        for (index, sticker) in pack.stickers.enumerated() {
            let num = index + 1
            if sticker.emojis.isEmpty {
                warnings.append("#\(num) '\(sticker.emote.name)' için emoji atanmamış (otomatik önerilecek).")
            } else if sticker.emojis.count > WhatsAppLimits.maxEmojisCount {
                warnings.append("#\(num) '\(sticker.emote.name)' için en fazla \(WhatsAppLimits.maxEmojisCount) emoji atanabilir.")
            }
            
            // Check cached file size if processed
            if let size = sticker.processedFileSize {
                let limit = sticker.emote.isAnimated ? WhatsAppLimits.maxAnimatedStickerBytes : WhatsAppLimits.maxStaticStickerBytes
                if size > limit {
                    let limitKB = limit / 1024
                    let actualKB = size / 1024
                    errors.append("#\(num) '\(sticker.emote.name)' boyutu (\(actualKB) KB) izin verilen sınırı (\(limitKB) KB) aşıyor.")
                }
            }
        }
        
        // 5. Tray icon check
        if pack.trayEmote == nil && pack.stickers.isEmpty {
            errors.append("Paket için bir menü simgesi (tray icon) belirlenmelidir.")
        }
        
        return PackValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
}
