import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif

/// Screen displaying all user sticker packs with integrated studio navigation and quick creation.
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
                    VStack(spacing: 16) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Henüz paketiniz yok")
                            .font(.headline)
                        Text("Sağ üstteki '+' butonuna basarak ilk çıkartma paketinizi anında oluşturabilirsiniz.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: createNewRandomPack) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Rastgele İsimli Paket Oluştur")
                            }
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.packs) { pack in
                        NavigationLink(destination: PackDetailStudioView(
                            pack: pack,
                            onPackDeleted: {
                                viewModel.loadPacks()
                            }
                        )) {
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
                                        
                                        if !pack.publisher.isEmpty {
                                            Text("• \(pack.publisher)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        if pack.isAnimatedPack {
                                            Text("• Hareketli")
                                                .font(.caption.bold())
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                
                                Spacer()
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
                        newPackTitle = RandomPackNameGenerator.generate()
                        showingNewPackAlert = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Yeni Paket Oluştur", isPresented: $showingNewPackAlert) {
                TextField("Paket Adı", text: $newPackTitle)
                Button("Oluştur") {
                    let chosenName = newPackTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let newPack = viewModel.createNewPack(name: chosenName.isEmpty ? nil : chosenName)
                    selectedPackForStudio = newPack
                }
                Button("Vazgeç", role: .cancel) {}
            }
            .navigationDestination(item: $selectedPackForStudio) { pack in
                PackDetailStudioView(pack: pack, onPackDeleted: {
                    viewModel.loadPacks()
                })
            }
            .onAppear {
                viewModel.loadPacks()
            }
        }
    }
    
    private func createNewRandomPack() {
        let newPack = viewModel.createNewPack()
        selectedPackForStudio = newPack
    }
}
