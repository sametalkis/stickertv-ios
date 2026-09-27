import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif
#if canImport(WhatsAppEngine)
import WhatsAppEngine
#endif

/// Sheet allowing user to customize the 1-3 emojis associated with a sticker.
public struct EmojiEditorSheet: View {
    public let sticker: StickerItem
    public let onSave: ([String]) -> Void
    
    @State private var currentEmojis: [String]
    @Environment(\.dismiss) private var dismiss
    
    private let quickSuggestions = ["😂", "🤣", "🐱", "🐶", "🐸", "❤️", "🔥", "😎", "😰", "💀", "🎉", "🤔", "🫡", "🙏", "🍔", "⚡️", "💯", "🗿", "👀", "🥳"]
    
    public init(sticker: StickerItem, onSave: @escaping ([String]) -> Void) {
        self.sticker = sticker
        self.onSave = onSave
        self._currentEmojis = State(initialValue: sticker.emojis)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Sticker Image Preview
                AsyncEmoteImageView(url: sticker.emote.thumbnailURL)
                    .frame(width: 90, height: 90)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                
                Text(sticker.emote.name)
                    .font(.headline)
                
                // Current Emojis
                VStack(spacing: 8) {
                    Text("Seçili Emojiler (\(currentEmojis.count)/\(WhatsAppLimits.maxEmojisCount))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 10) {
                        ForEach(currentEmojis, id: \.self) { emoji in
                            Button(action: {
                                currentEmojis.removeAll { $0 == emoji }
                            }) {
                                HStack(spacing: 4) {
                                    Text(emoji)
                                        .font(.title2)
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Random 3 Emojis Button
                Button(action: {
                    currentEmojis = EmojiSuggester.randomEmojis(count: 3)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "dice.fill")
                        Text("3 Rastgele Emoji Ata")
                    }
                    .font(.subheadline.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundColor(.accentColor)
                    .cornerRadius(12)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Quick Emoji Suggestions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hızlı Öneriler")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                        ForEach(quickSuggestions, id: \.self) { emoji in
                            Button(action: {
                                if !currentEmojis.contains(emoji) && currentEmojis.count < WhatsAppLimits.maxEmojisCount {
                                    currentEmojis.append(emoji)
                                }
                            }) {
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Emoji Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        onSave(currentEmojis.isEmpty ? EmojiSuggester.randomEmojis(count: 3) : currentEmojis)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
