import SwiftUI
#if canImport(SDWebImage)
import SDWebImage
#endif
#if canImport(SDWebImageWebPCoder)
import SDWebImageWebPCoder
#endif

/// Main iOS application entry point.
@main
public struct StickerTVApp: App {
    @StateObject private var environment = AppEnvironment.shared
    
    public init() {
        #if canImport(SDWebImage) && canImport(SDWebImageWebPCoder)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        #endif
    }
    
    public var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(environment)
        }
    }
}
