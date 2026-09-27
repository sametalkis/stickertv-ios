import Foundation

/// Generates creative, fun, and culturally relevant random names for sticker packs.
public struct RandomPackNameGenerator: Sendable {
    
    private static let prefixes = [
        "Neon", "Cosmic", "Hyper", "Ultra", "Spicy", "Golden", "Mega",
        "Super", "Cyber", "Retro", "Epic", "Turbo", "Secret", "Omega",
        "Chill", "Quantum", "Shadow", "Magic", "Pixel", "Atomic",
        "Legendary", "Wild", "Glitch", "Infinite", "Based"
    ]
    
    private static let subjects = [
        "Pepe", "KEKW", "Poggers", "Vibes", "Monka", "CatJam", "Squad",
        "Crew", "Legends", "Party", "Club", "Energy", "Dojo", "Express",
        "Galaxy", "GigaChad", "AYAYA", "Bedge", "LUL", "Bangers",
        "Stickers", "Vault", "Depot", "Station", "Tribe"
    ]
    
    /// Generates a two-part vibrant random name (e.g. "Hyper KEKW", "Cosmic Monka", "Neon Pepe").
    public static func generate() -> String {
        let prefix = prefixes.randomElement() ?? "Hyper"
        let subject = subjects.randomElement() ?? "Vibes"
        return "\(prefix) \(subject)"
    }
}
