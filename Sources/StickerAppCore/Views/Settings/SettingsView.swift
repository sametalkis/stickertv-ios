import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif
#if canImport(WhatsAppEngine)
import WhatsAppEngine
#endif

/// Settings screen showing active providers, WhatsApp sticker specifications, and storage management.
public struct SettingsView: View {
    @State private var cacheClearedNotice: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                // Section 1: Active & Future Providers (Multi-Source Architecture)
                Section(header: Text("Emote Kaynakları (Multi-Source)")) {
                    HStack {
                        Image(systemName: "tv.fill")
                            .foregroundColor(.purple)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SevenTV (7TV)")
                                .font(.body.weight(.medium))
                            Text("v4 GraphQL API (Aktif)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Image(systemName: "sparkle")
                            .foregroundColor(.orange)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("BetterTTV (BTTV)")
                                .font(.body.weight(.medium))
                            Text("Gelecek Sürüm")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("Yakında")
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .cornerRadius(6)
                    }
                    
                    HStack {
                        Image(systemName: "face.smiling.fill")
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("FrankerFaceZ (FFZ)")
                                .font(.body.weight(.medium))
                            Text("Gelecek Sürüm")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("Yakında")
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                }
                
                // Section 2: WhatsApp Technical Specifications
                Section(header: Text("WhatsApp Çıkartma Kuralları")) {
                    HStack {
                        Text("Paket Başına Çıkartma")
                        Spacer()
                        Text("3 - 30 Adet")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Görsel Çözünürlüğü")
                        Spacer()
                        Text("512 x 512 px")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Statik Çıkartma Boyutu")
                        Spacer()
                        Text("Maks 100 KB")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Hareketli Çıkartma Boyutu")
                        Spacer()
                        Text("Maks 500 KB")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Hareketli Süre Sınırı")
                        Spacer()
                        Text("Maks 6.0 sn")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Menü Simgesi (Tray Icon)")
                        Spacer()
                        Text("96 x 96 px (<50 KB)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Section 3: Storage & Cache Management
                Section(header: Text("Depolama")) {
                    Button(role: .destructive, action: {
                        ImageProcessingPipeline().clearCache()
                        cacheClearedNotice = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Dönüştürme Önbelleğini Temizle")
                        }
                    }
                    
                    if cacheClearedNotice {
                        Text("Önbellek başarıyla temizlendi.")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // Section 4: About
                Section(header: Text("Hakkında")) {
                    HStack {
                        Text("Uygulama")
                        Spacer()
                        Text("StickerTV for iOS")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ayarlar")
        }
    }
}
