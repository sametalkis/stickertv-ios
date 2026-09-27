import Foundation

/// Central registry managing available and active emote sources.
/// Allows dynamic extension with new providers without altering core app logic.
public final class EmoteSourceRegistry: @unchecked Sendable {
    public static let shared = EmoteSourceRegistry()
    
    private let lock = NSLock()
    private var sources: [String: any EmoteSourceProtocol] = [:]
    private var activeSourceId: String = ""
    
    public init() {}
    
    /// Registers a new provider into the registry.
    public func register(_ source: any EmoteSourceProtocol) {
        lock.lock()
        defer { lock.unlock() }
        sources[source.sourceId] = source
        if activeSourceId.isEmpty {
            activeSourceId = source.sourceId
        }
    }
    
    /// Returns a specific provider by its unique identifier.
    public func source(for id: String) -> (any EmoteSourceProtocol)? {
        lock.lock()
        defer { lock.unlock() }
        return sources[id]
    }
    
    /// Returns all registered providers.
    public var allSources: [any EmoteSourceProtocol] {
        lock.lock()
        defer { lock.unlock() }
        return Array(sources.values)
    }
    
    /// Sets the currently active provider.
    public func setActiveSource(id: String) {
        lock.lock()
        defer { lock.unlock() }
        if sources[id] != nil {
            activeSourceId = id
        }
    }
    
    /// Returns the currently active provider.
    public var activeSource: (any EmoteSourceProtocol)? {
        lock.lock()
        defer { lock.unlock() }
        return sources[activeSourceId] ?? sources.values.first
    }
}
