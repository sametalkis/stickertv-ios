import Foundation
import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif
#if canImport(WhatsAppEngine)
import WhatsAppEngine
#endif

/// ViewModel driving the Explore and Emote Search interface.
@MainActor
public final class ExploreViewModel: ObservableObject {
    @Published public var query: String = ""
    @Published public var selectedSort: EmoteSortOption = .trendingWeekly
    @Published public var filterOnlyAnimated: Bool = false
    @Published public var filterNsfw: Bool = false
    
    @Published public var items: [EmoteItem] = []
    @Published public var isLoading: Bool = false
    @Published public var isLoadingMore: Bool = false
    @Published public var errorMessage: String?
    
    @Published public var availablePacks: [StickerPack] = []
    @Published public var activePack: StickerPack
    @Published public var selectedEmoteForDetail: EmoteItem?
    @Published public var notificationToast: String?
    
    private let environment: AppEnvironment
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var searchDebounceTask: Task<Void, Never>?
    
    public init(environment: AppEnvironment = .shared) {
        self.environment = environment
        
        let existingPacks = environment.storage.loadPacks()
        self.availablePacks = existingPacks
        
        if let first = existingPacks.first {
            self.activePack = first
        } else {
            let defaultCreator = UserDefaults.standard.string(forKey: "defaultCreatorName") ?? "StickerTV"
            let initialPack = StickerPack(
                name: RandomPackNameGenerator.generate(),
                publisher: defaultCreator.isEmpty ? "StickerTV" : defaultCreator
            )
            environment.storage.save(pack: initialPack)
            self.activePack = initialPack
            self.availablePacks = [initialPack]
        }
    }
    
    public func refreshPacks() {
        let loaded = environment.storage.loadPacks()
        self.availablePacks = loaded
        if let current = loaded.first(where: { $0.id == activePack.id }) {
            self.activePack = current
        } else if let first = loaded.first {
            self.activePack = first
        }
    }
    
    public func selectPack(_ pack: StickerPack) {
        self.activePack = pack
        notificationToast = "Aktif paket: \(pack.name)"
    }
    
    public func createAndSelectNewPack() {
        let defaultCreator = UserDefaults.standard.string(forKey: "defaultCreatorName") ?? "StickerTV"
        let newPack = StickerPack(
            name: RandomPackNameGenerator.generate(),
            publisher: defaultCreator.isEmpty ? "StickerTV" : defaultCreator
        )
        environment.storage.save(pack: newPack)
        refreshPacks()
        self.activePack = newPack
        notificationToast = "'\(newPack.name)' paketi oluşturuldu ve seçildi!"
    }
    
    /// Loads initial data or triggers a search.
    public func loadInitialEmotes() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        do {
            guard let source = environment.registry.activeSource else {
                throw NetworkError.unknown("Aktif emote kaynağı bulunamadı.")
            }
            
            let filters = EmoteFilters(
                isAnimated: filterOnlyAnimated ? true : nil,
                isNsfw: filterNsfw ? true : false,
                exactMatch: nil,
                tags: []
            )
            
            let result = try await source.searchEmotes(
                query: query.isEmpty ? nil : query,
                sort: selectedSort,
                filters: filters,
                page: 1,
                perPage: 30
            )
            
            self.items = result.items
            self.totalPages = result.pageCount
            self.currentPage = 1
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Triggers search with debounce when text changes.
    public func onQueryChanged() {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000) // 350ms debounce
            guard !Task.isCancelled else { return }
            await loadInitialEmotes()
        }
    }
    
    /// Loads the next page of results.
    public func loadMoreIfNeeded(currentItem item: EmoteItem) async {
        guard let index = items.firstIndex(where: { $0.id == item.id }),
              index >= items.count - 6,
              currentPage < totalPages,
              !isLoadingMore else {
            return
        }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        
        do {
            guard let source = environment.registry.activeSource else { return }
            let filters = EmoteFilters(
                isAnimated: filterOnlyAnimated ? true : nil,
                isNsfw: filterNsfw ? true : false,
                exactMatch: nil,
                tags: []
            )
            
            let result = try await source.searchEmotes(
                query: query.isEmpty ? nil : query,
                sort: selectedSort,
                filters: filters,
                page: nextPage,
                perPage: 30
            )
            
            self.items.append(contentsOf: result.items)
            self.currentPage = nextPage
            self.totalPages = result.pageCount
        } catch {
            // Keep existing items on pagination failure
        }
        
        isLoadingMore = false
    }
    
    /// Adds an emote to the active pack.
    public func addToActivePack(emote: EmoteItem) {
        refreshPacks()
        
        if activePack.stickers.count >= WhatsAppLimits.maxStickerCount {
            notificationToast = "Paket dolu (Maksimum \(WhatsAppLimits.maxStickerCount) çıkartma)."
            return
        }
        
        if activePack.stickers.contains(where: { $0.emote.id == emote.id }) {
            notificationToast = "'\(emote.name)' zaten '\(activePack.name)' paketine ekli."
            return
        }
        
        let suggestedEmojis = EmojiSuggester.suggest(for: emote.name, tags: emote.tags)
        let sticker = StickerItem(emote: emote, emojis: suggestedEmojis)
        activePack.stickers.append(sticker)
        
        if activePack.trayEmote == nil {
            activePack.trayEmote = emote
        }
        
        activePack.updatedAt = Date()
        environment.storage.save(pack: activePack)
        refreshPacks()
        notificationToast = "'\(emote.name)' '\(activePack.name)' paketine eklendi! (\(activePack.stickers.count)/\(WhatsAppLimits.maxStickerCount))"
    }
    
    /// Removes an emote from the active pack.
    public func removeFromActivePack(emote: EmoteItem) {
        activePack.stickers.removeAll { $0.emote.id == emote.id }
        if activePack.trayEmote?.id == emote.id {
            activePack.trayEmote = activePack.stickers.first?.emote
        }
        activePack.updatedAt = Date()
        environment.storage.save(pack: activePack)
        refreshPacks()
        notificationToast = "'\(emote.name)' paketten çıkarıldı."
    }
}
