import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif

/// Screen displaying the user's saved sticker packs.
public struct MyPacksView: View {
    @StateObject private var viewModel = MyPacksViewModel()
    @State private var showingNewPackAlert: Bool = false
    @State private var newPackTitle: String = ""
    @State private var selectedPackForStudio: StickerPack?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                if viewModel.packs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("Kayıtlı paket bulunmuyor")
                            .font(.headline)
                        Text("Yeni bir paket oluşturarak 7TV emote'larını kaydetmeye başlayabilirsiniz.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.packs) { pack in
                        Button(action: {
                            selectedPackForStudio = pack
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemBackground))
                                    if let tray = pack.effectiveTrayEmote {
                                        AsyncEmoteImageView(url: tray.thumbnailURL)
                                            .padding(6)
                                    } else {
                                        Image(systemName: "photo.stack")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(width: 52, height: 52)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pack.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 8) {
                                        Text("\(pack.count) Çıkartma")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if pack.isAnimatedPack {
                                            Text("• Hareketli")
                                                .font(.caption.bold())
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: viewModel.deletePack)
                }
            }
            .navigationTitle("Paketlerim")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        newPackTitle = "Yeni Paket \(viewModel.packs.count + 1)"
                        showingNewPackAlert = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Yeni Paket Oluştur", isPresented: $showingNewPackAlert) {
                TextField("Paket Adı", text: $newPackTitle)
                Button("Oluştur") {
                    let newPack = viewModel.createNewPack(name: newPackTitle)
                    selectedPackForStudio = newPack
                }
                Button("Vazgeç", role: .cancel) {}
            }
            .sheet(item: $selectedPackForStudio) { pack in
                PackStudioView(pack: pack)
            }
            .onAppear {
                viewModel.loadPacks()
            }
        }
    }
}
