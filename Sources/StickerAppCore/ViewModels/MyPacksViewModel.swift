import Foundation
import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif

/// ViewModel managing user's saved sticker packs.
@MainActor
public final class MyPacksViewModel: ObservableObject {
    @Published public var packs: [StickerPack] = []
    
    private let environment: AppEnvironment
    
    public init(environment: AppEnvironment = .shared) {
        self.environment = environment
        loadPacks()
    }
    
    public func loadPacks() {
        self.packs = environment.storage.loadPacks()
    }
    
    public func createNewPack(name: String = "Yeni Paket") -> StickerPack {
        let newPack = StickerPack(name: name)
        environment.storage.save(pack: newPack)
        loadPacks()
        return newPack
    }
    
    public func deletePack(at offsets: IndexSet) {
        for index in offsets {
            let pack = packs[index]
            environment.storage.delete(packId: pack.id)
        }
        packs.remove(atOffsets: offsets)
    }
}
