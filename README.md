# StickerTV for iOS (7TV & Multi-Source WhatsApp Sticker App)

**StickerTV**, öncelikli olarak **SevenTV (7TV)** platformunun devasa emote arşivini keşfedip kişiselleştirilmiş paketler oluşturmanızı ve bunları tek tıkla **WhatsApp Çıkartması (Sticker)** olarak dışa aktarmanızı sağlayan, **Swift & SwiftUI** ile geliştirilmiş modüler bir iOS uygulamasıdır.

Uygulama, gelecekte **BetterTTV (BTTV)**, **FrankerFaceZ (FFZ)** veya özel kaynakların sıfır kod kırılmasıyla sisteme dahil edilebileceği **Provider (Sağlayıcı) Mimarisi** üzerine inşa edilmiştir.

---

## 📲 SideStore & AltStore Kaynağı (Community Source)

StickerTV'yi **SideStore** veya **AltStore** mağazanıza ekleyerek IPA indirmekle uğraşmadan tek tıkla kurabilir ve yeni sürümler çıktığında doğrudan mağaza içinden otomatik güncelleyebilirsiniz!

### ⚡ Tek Tıkla Mağazana Ekle:
* [📲 **SideStore'a Ekle**](sidestore://source?url=https%3A%2F%2Fraw.githubusercontent.com%2Fsametalkis%2Fstickertv-ios%2Fmaster%2Fapps.json) *(iPhone'unuzdan bu linke tıklayın)*
* [📲 **AltStore'a Ekle**](altstore://source?url=https%3A%2F%2Fraw.githubusercontent.com%2Fsametalkis%2Fstickertv-ios%2Fmaster%2Fapps.json) *(iPhone'unuzdan bu linke tıklayın)*

### 📋 Manuel Kaynak URL'si:
Aşağıdaki bağlantıyı kopyalayıp SideStore / AltStore uygulamasındaki **Sources ➔ `+`** butonuna yapıştırmanız yeterlidir:
```text
https://raw.githubusercontent.com/sametalkis/stickertv-ios/master/apps.json
```

---

## 🏛 Mimari Yapı

Proje, katmanlı ve birbirinden bağımsız 4 ana modülden oluşur:

```
┌────────────────────────────────────────────────────────┐
│                   StickerAppCore                       │
│        (SwiftUI - Keşfet, Paket Stüdyosu, Ayarlar)      │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                    StickerCore                         │
│     (Evrensel Modeller, Protokoller, Kaynak Kaydı)     │
└──────────────────────────┬─────────────────────────────┘
                           │
       ┌───────────────────┴───────────────────┐
       ▼                                       ▼
┌─────────────────────────────┐ ┌─────────────────────────────┐
│       SevenTVSource         │ │       WhatsAppEngine        │
│    (v4 GraphQL EmoteSearch) │ │ (Akıllı Optimizasyon & Köprü)│
└─────────────────────────────┘ └─────────────────────────────┘
```

### 1. `StickerCore`
* **Modeller:** `EmoteItem`, `EmoteImage`, `StickerPack`, `StickerItem`, `EmoteFilters`, `EmoteSortOption`.
* **Protokoller:** `EmoteSourceProtocol` (Tüm emote sağlayıcılarının uyması gereken sözleşme).
* **Kayıt Yönetimi (`EmoteSourceRegistry`):** Çalışma anında sağlayıcıları dinamik olarak kaydeden ve aktif sağlayıcıyı yöneten merkez.
* **Akıllı Emoji Tahmini (`EmojiSuggester`):** Emote adı ve etiketlerini analiz ederek WhatsApp'ın zorunlu kıldığı 1-3 emojiyi otomatik önerir.

### 2. `SevenTVSource`
* 7TV'nin modern **v4 GraphQL API** (`https://7tv.io/v4/gql`) servisini kullanır.
* `EmoteSearch` operasyonu üzerinden arama, etiket filtresi, sıralama (Trending, Top, Newest) ve animasyon filtrelemesini yönetir.
* CDN üzerindeki yüksek çözünürlüklü WebP/AVIF varlıklarını evrensel domain modellerine dönüştürür.

### 3. `WhatsAppEngine`
* **WhatsApp Teknik Kuralları (`WhatsAppLimits`):**
  * Paket başına **3 ile 30 çıkartma** sınırı.
  * Tam olarak **512 x 512 px** çözünürlük (16 px şeffaf kenar boşluğu ile).
  * Statik çıkartmalar için maksimum **100 KB**.
  * Hareketli (Animated) çıkartmalar için maksimum **500 KB** (güvenli hedef: **480 KB**).
  * Hareketli çıkartmalar için maksimum **6.0 saniye** süre, 8 - 60 FPS arası döngü.
  * Menü simgesi (Tray icon) için **96 x 96 px** ve maksimum **50 KB**.
* **Akıllı Hareketli WebP Optimizasyonu (`AnimatedWebPOptimizer`):**
  * 6 saniyeyi aşan animasyonları hızlandırma veya süre kırpma.
  * 500 KB sınırını aşan animasyonlarda görsel akıcılığı bozmadan akıllı kare seyreltme (frame subsampling; örn. 60fps/30fps -> 20fps) ve kademeli kayıplı WebP sıkıştırması.
* **Tuval Hizalama (`CanvasResizer`):** En/boy oranını koruyarak görseli 512x512 şeffaf tuvale ortalama.
* **Pano Köprüsü (`WhatsAppPasteboardBridge`):** Resmi `net.whatsapp.WhatsApp.StickerManager.share` panosu ve `whatsapp://stickerPack` URL şeması üzerinden WhatsApp ile iletişim.

### 4. `StickerAppCore`
* **Keşfet (Explore):** Canlı arama (debounced), kategori/sıralama çipleri, sonsuz kaydırma (infinite scroll) ve tek dokunuşla pakete ekleme.
* **Paket Stüdyosu (Pack Studio):** 3-30 çıkartma durum çubuğu, her çıkartma için emoji düzenleyici, paket adı/yayıncı düzenleme ve WhatsApp'a ekleme butonu.
* **Paketlerim (My Packs):** Yerel olarak kaydedilen paketleri saklama, düzenleme ve silme.
* **Ayarlar (Settings):** Aktif sağlayıcı durumu, önbellek temizleme ve WhatsApp kuralları kılavuzu.

---

## 🚀 Yeni Bir Kaynak (Provider) Nasıl Eklenir?

Gelecekte **BetterTTV** veya başka bir platform eklemek istediğinizde:

1. `EmoteSourceProtocol` protokolüne uyan bir struct/class yazın:
```swift
import StickerCore

public final class BTTVProvider: EmoteSourceProtocol {
    public let sourceId = "bttv"
    public let displayName = "BetterTTV"
    public let iconSystemName = "sparkle"
    public let supportsAnimation = true

    public func searchEmotes(...) async throws -> EmoteSearchResult { ... }
    public func fetchTrending(...) async throws -> EmoteSearchResult { ... }
    public func fetchEmoteDetails(id: String) async throws -> EmoteItem { ... }
}
```

2. `AppEnvironment` içerisinde kayıt edin:
```swift
EmoteSourceRegistry.shared.register(BTTVProvider())
```

Mevcut arayüz, arama motoru ve WhatsApp köprüsü hiçbir değişikliğe gerek kalmadan yeni kaynağı anında destekleyecektir!

---

## 🛠 Kurulum ve Çalıştırma

1. Repoyu klonlayın.
2. macOS üzerinde Xcode 15+ ile açın:
   * Doğrudan klasörü Xcode'a sürükleyerek Swift Package olarak açabilir veya projenize ekleyebilirsiniz.
3. Testleri çalıştırmak için:
```bash
swift test
```
4. iOS 17+ simülatör veya gerçek cihaz üzerinde çalıştırın.

---

## 📄 Lisans
MIT License.
