import SwiftUI
import StickerCore
import WhatsAppEngine

/// Main studio interface for building, editing, and exporting the sticker pack to WhatsApp.
public struct PackStudioView: View {
    @StateObject private var viewModel: PackStudioViewModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 95, maximum: 115), spacing: 12)
    ]
    
    public init(pack: StickerPack = StickerPack()) {
        self._viewModel = StateObject(wrappedValue: PackStudioViewModel(pack: pack))
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header: Pack Info & Progress Bar
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // Tray icon preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                            if let tray = viewModel.pack.effectiveTrayEmote {
                                AsyncEmoteImageView(url: tray.thumbnailURL)
                                    .padding(6)
                            } else {
                                Image(systemName: "app.badge")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 54, height: 54)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Paket Adı", text: $viewModel.pack.name)
                                .font(.headline)
                                .onChange(of: viewModel.pack.name) { _, _ in
                                    viewModel.updateValidation()
                                }
                            
                            TextField("Yayıncı Adı", text: $viewModel.pack.publisher)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .onChange(of: viewModel.pack.publisher) { _, _ in
                                    viewModel.updateValidation()
                                }
                        }
                    }
                    
                    // Sticker Count Progress Bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Çıkartma Sayısı")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.pack.count) / \(WhatsAppLimits.maxStickerCount)")
                                .font(.caption.bold())
                                .foregroundColor(viewModel.pack.hasValidStickerCount ? .green : .orange)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                
                                let fraction = min(1.0, Double(viewModel.pack.count) / Double(WhatsAppLimits.maxStickerCount))
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(viewModel.pack.hasValidStickerCount ? Color.green : Color.orange)
                                    .frame(width: geo.size.width * fraction)
                            }
                        }
                        .frame(height: 6)
                        
                        if viewModel.pack.count < WhatsAppLimits.minStickerCount {
                            Text("WhatsApp için en az \(WhatsAppLimits.minStickerCount - viewModel.pack.count) çıkartma daha eklemelisiniz.")
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Stickers Grid
                if viewModel.pack.stickers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.grid.3x3.topleft.filled")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Henüz çıkartma eklenmedi")
                            .font(.headline)
                        Text("'Keşfet' sekmesinden 7TV emote'larını arayıp paketinize ekleyebilirsiniz.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.pack.stickers) { sticker in
                                VStack(spacing: 4) {
                                    ZStack(alignment: .topTrailing) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.secondarySystemBackground))
                                            
                                            AsyncEmoteImageView(url: sticker.emote.thumbnailURL)
                                                .padding(8)
                                        }
                                        .frame(height: 85)
                                        
                                        // Delete button
                                        Button(action: {
                                            viewModel.removeSticker(id: sticker.id)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Circle().fill(Color.white))
                                        }
                                        .padding(4)
                                    }
                                    
                                    // Emojis badge & edit trigger
                                    Button(action: {
                                        viewModel.editingSticker = sticker
                                    }) {
                                        HStack(spacing: 2) {
                                            Text(sticker.emojis.joined())
                                                .font(.caption2)
                                            Image(systemName: "pencil")
                                                .font(.system(size: 8))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(.tertiarySystemBackground))
                                        .cornerRadius(6)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // Bottom Export Bar
                VStack(spacing: 8) {
                    if let error = viewModel.exportError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    if let success = viewModel.exportSuccessMessage {
                        Text(success)
                            .font(.caption.bold())
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        Task { await viewModel.exportToWhatsApp() }
                    }) {
                        HStack {
                            if viewModel.isExporting {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 6)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                            }
                            Text(viewModel.isExporting ? "Hazırlanıyor..." : "WhatsApp'a Aktar")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.validationResult.isValid && !viewModel.isExporting ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .disabled(!viewModel.validationResult.isValid || viewModel.isExporting)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Paket Stüdyosu")
            .sheet(item: $viewModel.editingSticker) { sticker in
                EmojiEditorSheet(
                    sticker: sticker,
                    onSave: { newEmojis in
                        viewModel.updateEmojis(stickerId: sticker.id, emojis: newEmojis)
                    }
                )
            }
        }
    }
}
