import SwiftUI
import StickerCore

/// Modal bottom sheet presenting detailed information about a selected emote.
public struct EmoteDetailSheet: View {
    public let emote: EmoteItem
    public let isAdded: Bool
    public let onAddToggle: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        emote: EmoteItem,
        isAdded: Bool,
        onAddToggle: @escaping () -> Void
    ) {
        self.emote = emote
        self.isAdded = isAdded
        self.onAddToggle = onAddToggle
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Large Emote Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemBackground))
                    
                    AsyncEmoteImageView(url: emote.preferredStickerImageURL)
                        .padding(24)
                }
                .frame(height: 220)
                .padding(.horizontal)
                
                // Emote Details
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(emote.name)
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        if emote.isAnimated {
                            Label("Hareketli", systemImage: "sparkles")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        } else {
                            Text("Statik")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.gray.opacity(0.15))
                                .foregroundColor(.secondary)
                                .cornerRadius(8)
                        }
                    }
                    
                    if let owner = emote.ownerName {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.secondary)
                            Text("Yükleyen: \(owner)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Tags
                    if !emote.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Etiketler")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(emote.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(.tertiarySystemBackground))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Add / Remove from Active Pack Button
                Button(action: {
                    onAddToggle()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: isAdded ? "trash" : "plus.circle.fill")
                        Text(isAdded ? "Paketten Çıkar" : "Paketime Ekle")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAdded ? Color.red.opacity(0.15) : Color.accentColor)
                    .foregroundColor(isAdded ? .red : .white)
                    .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Emote Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}
