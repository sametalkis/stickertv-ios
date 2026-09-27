import Foundation

/// Official WhatsApp Sticker specifications and hard limits.
public struct WhatsAppLimits {
    /// Minimum stickers allowed in a pack.
    public static let minStickerCount = 3
    
    /// Maximum stickers allowed in a pack.
    public static let maxStickerCount = 30
    
    /// Exact width and height for sticker images in pixels.
    public static let stickerDimension = 512
    
    /// Recommended transparent margin inside the 512x512 canvas.
    public static let recommendedMargin = 16
    
    /// Maximum content dimension inside the 512x512 canvas (512 - 2*16 = 480).
    public static let maxContentDimension = 480
    
    /// Exact width and height for the tray icon in pixels.
    public static let trayIconDimension = 96
    
    /// Maximum file size for a static sticker (100 KB).
    public static let maxStaticStickerBytes = 100 * 1024
    
    /// Maximum file size for an animated sticker (500 KB).
    public static let maxAnimatedStickerBytes = 500 * 1024
    
    /// Safe target threshold for animated stickers to prevent rejection (480 KB).
    public static let safeAnimatedStickerBytes = 480 * 1024
    
    /// Maximum file size for the tray icon (50 KB).
    public static let maxTrayIconBytes = 50 * 1024
    
    /// Maximum animation duration in seconds.
    public static let maxAnimationDurationSeconds: Double = 6.0
    
    /// Minimum animation frame rate.
    public static let minAnimationFPS: Double = 8.0
    
    /// Maximum animation frame rate.
    public static let maxAnimationFPS: Double = 60.0
    
    /// Minimum emojis per sticker.
    public static let minEmojisCount = 1
    
    /// Maximum emojis per sticker.
    public static let maxEmojisCount = 3
    
    /// WhatsApp custom pasteboard identifier.
    public static let pasteboardType = "net.whatsapp.WhatsApp.StickerManager.share"
    
    /// WhatsApp sticker pack deep link URL scheme.
    public static let urlScheme = "whatsapp://stickerPack"
}
