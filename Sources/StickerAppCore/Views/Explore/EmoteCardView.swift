import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif

/// Card representation of an emote in the Explore grid.
public struct EmoteCardView: View {
    public let emote: EmoteItem
    public let isAdded: Bool
    public let onAddTap: () -> Void
    public let onCardTap: () -> Void
    
    public init(
        emote: EmoteItem,
        isAdded: Bool = false,
        onAddTap: @escaping () -> Void,
        onCardTap: @escaping () -> Void
    ) {
        self.emote = emote
        self.isAdded = isAdded
        self.onAddTap = onAddTap
        self.onCardTap = onCardTap
    }
    
    public var body: some View {
        Button(action: onCardTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                        
                        AsyncEmoteImageView(url: emote.thumbnailURL)
                            .padding(12)
                    }
                    .frame(height: 100)
                    
                    if emote.isAnimated {
                        Text("GIF")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.blue)
                            .cornerRadius(6)
                            .padding(6)
                    }
                }
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(emote.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if let owner = emote.ownerName {
                            Text(owner)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer(minLength: 4)
                    
                    Button(action: onAddTap) {
                        Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(isAdded ? .green : .accentColor)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 4)
            }
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
