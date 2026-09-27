import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif

/// Root tab bar view connecting Explore, My Packs (with integrated Studio), and Settings.
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
            
            MyPacksView()
                .tabItem {
                    Label("Paketlerim", systemImage: "tray.full.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}
