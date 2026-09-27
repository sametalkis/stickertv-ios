import SwiftUI
import StickerCore
import WhatsAppEngine

/// Primary discovery screen with search, sorting, and filter controls.
public struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    
    private let columns = [
        GridItem(.adaptive(minimum: 105, maximum: 130), spacing: 12)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters & Sort Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Menu {
                            ForEach(EmoteSortOption.allCases) { sort in
                                Button(action: {
                                    viewModel.selectedSort = sort
                                    Task { await viewModel.loadInitialEmotes() }
                                }) {
                                    HStack {
                                        Text(sort.localizedTitle)
                                        if viewModel.selectedSort == sort {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.arrow.down")
                                Text(viewModel.selectedSort.localizedTitle)
                            }
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color(.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(20)
                        }
                        
                        // Animated Only Filter Toggle
                        Button(action: {
                            viewModel.filterOnlyAnimated.toggle()
                            Task { await viewModel.loadInitialEmotes() }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                Text("Sadece Hareketli")
                            }
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(viewModel.filterOnlyAnimated ? Color.blue : Color(.secondarySystemBackground))
                            .foregroundColor(viewModel.filterOnlyAnimated ? .white : .primary)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                
                // Emote Grid
                ZStack {
                    if viewModel.isLoading {
                        ProgressView("Emotelar yükleniyor...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("Yükleme başarısız:")
                                .font(.headline)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Tekrar Dene") {
                                Task { await viewModel.loadInitialEmotes() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.items.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("Sonuç bulunamadı.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewModel.items) { emote in
                                    let isAdded = viewModel.activePack.stickers.contains { $0.emote.id == emote.id }
                                    EmoteCardView(
                                        emote: emote,
                                        isAdded: isAdded,
                                        onAddTap: {
                                            viewModel.addToActivePack(emote: emote)
                                        },
                                        onCardTap: {
                                            viewModel.selectedEmoteForDetail = emote
                                        }
                                    )
                                    .task {
                                        await viewModel.loadMoreIfNeeded(currentItem: emote)
                                    }
                                }
                            }
                            .padding()
                            
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("7TV Keşfet")
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Emote ara (örn. catJAM, KEKW)..."
            )
            .onChange(of: viewModel.query) { _, _ in
                viewModel.onQueryChanged()
            }
            .task {
                if viewModel.items.isEmpty {
                    await viewModel.loadInitialEmotes()
                }
            }
            .sheet(item: $viewModel.selectedEmoteForDetail) { emote in
                let isAdded = viewModel.activePack.stickers.contains { $0.emote.id == emote.id }
                EmoteDetailSheet(
                    emote: emote,
                    isAdded: isAdded,
                    onAddToggle: {
                        if isAdded {
                            viewModel.activePack.stickers.removeAll { $0.emote.id == emote.id }
                        } else {
                            viewModel.addToActivePack(emote: emote)
                        }
                    }
                )
            }
            .overlay(alignment: .bottom) {
                if let toast = viewModel.notificationToast {
                    Text(toast)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(25)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    viewModel.notificationToast = nil
                                }
                            }
                        }
                }
            }
        }
    }
}
