import Foundation
import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif
#if canImport(WhatsAppEngine)
import WhatsAppEngine
#endif

/// ViewModel controlling the Sticker Pack Studio and WhatsApp export.
@MainActor
public final class PackStudioViewModel: ObservableObject {
    @Published public var pack: StickerPack
    @Published public var validationResult: PackValidationResult
    @Published public var isExporting: Bool = false
    @Published public var exportError: String?
    @Published public var exportSuccessMessage: String?
    @Published public var editingSticker: StickerItem?
    
    private let environment: AppEnvironment
    
    public init(pack: StickerPack, environment: AppEnvironment = .shared) {
        self.pack = pack
        self.environment = environment
        self.validationResult = WhatsAppValidationEngine.validate(pack: pack)
    }
    
    public func updateValidation() {
        self.validationResult = WhatsAppValidationEngine.validate(pack: pack)
        environment.storage.save(pack: pack)
    }
    
    public func removeSticker(id: UUID) {
        pack.stickers.removeAll { $0.id == id }
        if pack.trayEmote?.id == pack.stickers.first?.emote.id {
            pack.trayEmote = pack.stickers.first?.emote
        }
        updateValidation()
    }
    
    public func updateEmojis(stickerId: UUID, emojis: [String]) {
        guard let index = pack.stickers.firstIndex(where: { $0.id == stickerId }) else { return }
        pack.stickers[index].emojis = emojis
        updateValidation()
    }
    
    public func setAsTrayIcon(emote: EmoteItem) {
        pack.trayEmote = emote
        updateValidation()
    }
    
    public func exportToWhatsApp() async {
        guard validationResult.isValid else {
            exportError = validationResult.errors.joined(separator: "\n")
            return
        }
        
        isExporting = true
        exportError = nil
        exportSuccessMessage = nil
        
        do {
            try await environment.whatsAppBridge.export(pack: pack)
            exportSuccessMessage = "Paket başarıyla WhatsApp'a aktarıldı!"
        } catch {
            exportError = error.localizedDescription
        }
        
        isExporting = false
    }
}
