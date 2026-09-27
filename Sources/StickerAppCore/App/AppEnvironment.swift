import Foundation
#if canImport(StickerCore)
import StickerCore
#endif
#if canImport(SevenTVSource)
import SevenTVSource
#endif
#if canImport(WhatsAppEngine)
import WhatsAppEngine
#endif

/// App-wide dependency container and runtime environment.
public final class AppEnvironment: ObservableObject, @unchecked Sendable {
    public static let shared = AppEnvironment()
    
    public let registry: EmoteSourceRegistry
    public let whatsAppBridge: WhatsAppPasteboardBridge
    public let storage: LocalPackStorage
    
    public init() {
        self.registry = EmoteSourceRegistry.shared
        self.whatsAppBridge = WhatsAppPasteboardBridge()
        self.storage = LocalPackStorage.shared
        
        // Register primary providers
        let sevenTV = SevenTVProvider()
        registry.register(sevenTV)
        registry.setActiveSource(id: sevenTV.sourceId)
    }
}
