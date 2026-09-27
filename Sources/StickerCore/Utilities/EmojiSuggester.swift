import Foundation

/// Provides intelligent emoji recommendations for an emote based on its name and tags.
/// This fulfills WhatsApp's requirement that every sticker must have 1-3 emojis associated with it.
public struct EmojiSuggester: Sendable {
    
    private static let emojiMappings: [(keywords: [String], emojis: [String])] = [
        (["cat", "jam", "meow", "kitty", "neko"], ["🐱", "😻", "🐾"]),
        (["dog", "doge", "puppy", "bark", "woof"], ["🐶", "🐕", "🦴"]),
        (["kek", "kekw", "lol", "lmao", "haha", "giggle", "joy"], ["😂", "🤣", "😹"]),
        (["pepe", "frog", "ribbit", "peepo"], ["🐸", "💚"]),
        (["sad", "cry", "sob", "tear", "depressed"], ["😢", "😭", "😿"]),
        (["rage", "mad", "angry", "anger", "malding"], ["😡", "🤬", "💢"]),
        (["love", "heart", "kiss", "cute", "wholesome"], ["❤️", "🥰", "💖"]),
        (["fire", "lit", "hot", "burn", "hype"], ["🔥", "⚡️", "💥"]),
        (["cool", "sunglasses", "based", "sigma", "gigachad"], ["😎", "🕶️", "🗿"]),
        (["monka", "nervous", "sweat", "scared", "fear", "anxiety"], ["😰", "😨", "👀"]),
        (["sus", "among", "imposter"], ["📮", "🔍", "🤫"]),
        (["dead", "skull", "rip", "skeleton"], ["💀", "☠️"]),
        (["party", "celebrate", "dance", "rave", "vibing"], ["🎉", "🥳", "💃"]),
        (["clown", "circus", "honk"], ["🤡", "🎪"]),
        (["sleep", "bed", "tired", "zzz", "snore"], ["😴", "💤", "🥱"]),
        (["think", "smart", "brain", "galaxy", "ponder"], ["🤔", "🧠", "💡"]),
        (["salute", "o7", "respect", "honor"], ["🫡", "🎖️"]),
        (["pray", "bless", "amen", "please", "beg"], ["🙏", "✨"]),
        (["money", "rich", "stonks", "cash"], ["💰", "💵", "🤑"]),
        (["food", "eat", "nom", "burger", "pizza"], ["🍔", "🍕", "😋"])
    ]
    
    /// Suggests 1 to 3 emojis based on the emote's name and tags.
    public static func suggest(for emoteName: String, tags: [String] = []) -> [String] {
        let normalized = (emoteName.lowercased() + " " + tags.joined(separator: " ").lowercased())
        
        var matchedEmojis: [String] = []
        
        for mapping in emojiMappings {
            for keyword in mapping.keywords {
                if normalized.contains(keyword) {
                    for emoji in mapping.emojis where !matchedEmojis.contains(emoji) {
                        matchedEmojis.append(emoji)
                        if matchedEmojis.count >= 3 {
                            return matchedEmojis
                        }
                    }
                    break
                }
            }
        }
        
        // Default fallback if no specific keywords match
        if matchedEmojis.isEmpty {
            return ["💬"]
        }
        
        return Array(matchedEmojis.prefix(3))
    }
}
