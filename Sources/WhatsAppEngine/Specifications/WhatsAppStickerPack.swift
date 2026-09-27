import Foundation

/// JSON schema conforming directly to WhatsApp's third-party sticker pack interface.
public struct WhatsAppStickerPackPayload: Codable, Sendable {
    public let identifier: String
    public let name: String
    public let publisher: String
    public let trayImageFileName: String?
    public let trayImageData: String? // Base64 representation
    public let publisherEmail: String?
    public let publisherWebsite: String?
    public let privacyPolicyWebsite: String?
    public let licenseAgreementWebsite: String?
    public let animatedStickerPack: Bool
    public let stickers: [WhatsAppStickerPayload]
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case publisher
        case trayImageFileName = "tray_image_file"
        case trayImageData = "tray_image"
        case publisherEmail = "publisher_email"
        case publisherWebsite = "publisher_website"
        case privacyPolicyWebsite = "privacy_policy_website"
        case licenseAgreementWebsite = "license_agreement_website"
        case animatedStickerPack = "animated_sticker_pack"
        case stickers
    }
    
    public init(
        identifier: String,
        name: String,
        publisher: String,
        trayImageFileName: String? = nil,
        trayImageData: String? = nil,
        publisherEmail: String? = nil,
        publisherWebsite: String? = nil,
        privacyPolicyWebsite: String? = nil,
        licenseAgreementWebsite: String? = nil,
        animatedStickerPack: Bool,
        stickers: [WhatsAppStickerPayload]
    ) {
        self.identifier = identifier
        self.name = name
        self.publisher = publisher
        self.trayImageFileName = trayImageFileName
        self.trayImageData = trayImageData
        self.publisherEmail = publisherEmail
        self.publisherWebsite = publisherWebsite
        self.privacyPolicyWebsite = privacyPolicyWebsite
        self.licenseAgreementWebsite = licenseAgreementWebsite
        self.animatedStickerPack = animatedStickerPack
        self.stickers = stickers
    }
}

public struct WhatsAppStickerPayload: Codable, Sendable {
    public let imageFileName: String?
    public let imageData: String? // Base64 encoded WebP data
    public let emojis: [String]
    
    enum CodingKeys: String, CodingKey {
        case imageFileName = "image_file"
        case imageData = "image_data"
        case emojis
    }
    
    public init(
        imageFileName: String? = nil,
        imageData: String? = nil,
        emojis: [String]
    ) {
        self.imageFileName = imageFileName
        self.imageData = imageData
        self.emojis = emojis
    }
}
