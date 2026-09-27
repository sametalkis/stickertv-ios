import Foundation
import StickerCore

/// Local persistence manager for user-created sticker packs using JSON disk storage.
public final class LocalPackStorage: @unchecked Sendable {
    public static let shared = LocalPackStorage()
    
    private let directoryURL: URL
    private let fileManager = FileManager.default
    private let lock = NSLock()
    
    public init() {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.directoryURL = docs.appendingPathComponent("SavedStickerPacks", isDirectory: true)
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
    
    /// Loads all saved packs.
    public func loadPacks() -> [StickerPack] {
        lock.lock()
        defer { lock.unlock() }
        
        guard let files = try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else {
            return []
        }
        
        let decoder = JSONDecoder()
        var packs: [StickerPack] = []
        for file in files where file.pathExtension == "json" {
            if let data = try? Data(contentsOf: file),
               let pack = try? decoder.decode(StickerPack.self, from: data) {
                packs.append(pack)
            }
        }
        
        return packs.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    /// Saves or updates a sticker pack.
    public func save(pack: StickerPack) {
        lock.lock()
        defer { lock.unlock() }
        
        let fileURL = directoryURL.appendingPathComponent("\(pack.id.uuidString).json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(pack) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
    
    /// Deletes a sticker pack by ID.
    public func delete(packId: UUID) {
        lock.lock()
        defer { lock.unlock() }
        let fileURL = directoryURL.appendingPathComponent("\(packId.uuidString).json")
        try? fileManager.removeItem(at: fileURL)
    }
}
