import Foundation

/// Provides emoji recommendations for an emote based on its name and tags,
/// guaranteeing 3 vibrant, expressive emojis per sticker.
public struct EmojiSuggester: Sendable {
    
    public static let fallbackEmojiPool = [
        "😂", "🔥", "💀", "🗿", "😎", "👀", "🥳", "🤯",
        "⚡️", "💯", "🫡", "😈", "🤪", "🤡", "🫠", "🥶",
        "🤩", "✨", "👏", "🙌", "💥", "🚀", "🍿", "🎉",
        "😹", "😳", "🕺", "🤝", "💪", "👾", "🤙", "🤌",
        "🤣", "🤤", "🤭", "🧐", "🎯", "👑", "🍕", "🍔"
    ]
    
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
    
    /// Generates N distinct random emojis from the vibrant pool.
    public static func randomEmojis(count: Int = 3) -> [String] {
        var pool = fallbackEmojiPool.shuffled()
        return Array(pool.prefix(max(1, min(count, 3))))
    }
    
    /// Suggests exactly 1 to 3 emojis based on keywords, filling remaining slots with vibrant random emojis.
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
        
        // Fill up to 3 emojis with fun, varied emojis if less than 3 matched
        if matchedEmojis.count < 3 {
            let needed = 3 - matchedEmojis.count
            var pool = fallbackEmojiPool.filter { !matchedEmojis.contains($0) }.shuffled()
            matchedEmojis.append(contentsOf: pool.prefix(needed))
        }
        
        return Array(matchedEmojis.prefix(3))
    }
}
