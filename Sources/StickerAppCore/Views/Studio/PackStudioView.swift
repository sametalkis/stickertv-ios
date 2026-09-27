import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif

/// Forwarding view maintaining backwards compatibility with PackStudioView callers.
public struct PackStudioView: View {
    private let pack: StickerPack
    
    public init(pack: StickerPack = StickerPack()) {
        self.pack = pack
    }
    
    public var body: some View {
        PackDetailStudioView(pack: pack)
    }
}
