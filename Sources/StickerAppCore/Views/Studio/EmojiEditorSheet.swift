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
    
    private let quickSuggestions = ["😂", "🤣", "🐱", "🐶", "🐸", "❤️", "🔥", "😎", "😰", "💀", "🎉", "🤔", "🫡", "🙏", "🍔"]
    
    public init(sticker: StickerItem, onSave: @escaping ([String]) -> Void) {
        self.sticker = sticker
        self.onSave = onSave
        self._currentEmojis = State(initialValue: sticker.emojis)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Sticker Image Preview
                AsyncEmoteImageView(url: sticker.emote.thumbnailURL)
                    .frame(width: 100, height: 100)
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
                    
                    HStack(spacing: 12) {
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
                
                Divider()
                    .padding(.horizontal)
                
                // Quick Emoji Suggestions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hızlı Öneriler")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 12) {
                        ForEach(quickSuggestions, id: \.self) { emoji in
                            Button(action: {
                                if !currentEmojis.contains(emoji) && currentEmojis.count < WhatsAppLimits.maxEmojisCount {
                                    currentEmojis.append(emoji)
                                }
                            }) {
                                Text(emoji)
                                    .font(.system(size: 32))
                                    .frame(maxWidth: .infinity, minHeight: 48)
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
                        onSave(currentEmojis.isEmpty ? ["💬"] : currentEmojis)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
