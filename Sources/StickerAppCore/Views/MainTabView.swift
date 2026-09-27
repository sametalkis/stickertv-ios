import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif

/// Root tab bar view connecting Explore, Studio, My Packs, and Settings.
public struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Label("Keşfet", systemImage: "magnifyingglass")
                }
                .tag(0)
            
            PackStudioView()
                .tabItem {
                    Label("Stüdyo", systemImage: "sparkles.rectangle.stack.fill")
                }
                .tag(1)
            
            MyPacksView()
                .tabItem {
                    Label("Paketlerim", systemImage: "tray.full.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
    }
}
