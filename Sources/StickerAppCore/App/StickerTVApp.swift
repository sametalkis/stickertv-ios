import SwiftUI

/// Main iOS application entry point.
@main
public struct StickerTVApp: App {
    @StateObject private var environment = AppEnvironment.shared
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(environment)
        }
    }
}
