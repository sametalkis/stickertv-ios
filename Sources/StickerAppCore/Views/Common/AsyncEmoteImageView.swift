import SwiftUI
#if canImport(StickerCore)
import StickerCore
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SDWebImage)
import SDWebImage
#endif

#if canImport(UIKit) && canImport(SDWebImage)
/// Native UIKit wrapper using SDAnimatedImageView to decode and animate WebP and GIFs.
public struct SDAnimatedImageRepresentable: UIViewRepresentable {
    public let url: URL?
    public let contentMode: UIView.ContentMode
    
    public init(url: URL?, contentMode: UIView.ContentMode = .scaleAspectFit) {
        self.url = url
        self.contentMode = contentMode
    }
    
    public func makeUIView(context: Context) -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.autoPlayAnimatedImage = true
        imageView.shouldIncrementalLoad = true
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.medium
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return imageView
    }
    
    public func updateUIView(_ uiView: SDAnimatedImageView, context: Context) {
        if uiView.sd_imageURL != url {
            if let url = url {
                uiView.sd_setImage(with: url)
            } else {
                uiView.image = nil
            }
        }
    }
}
#endif

/// Reusable asynchronous image view for displaying animated (GIF/WebP) and static emote previews.
public struct AsyncEmoteImageView: View {
    public let url: URL?
    public let contentMode: ContentMode
    
    public init(url: URL?, contentMode: ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }
    
    public var body: some View {
        #if canImport(UIKit) && canImport(SDWebImage)
        if let url = url {
            SDAnimatedImageRepresentable(
                url: url,
                contentMode: contentMode == .fill ? .scaleAspectFill : .scaleAspectFit
            )
        } else {
            placeholder
        }
        #else
        if let url = url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color(.systemGray6)
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failure:
                    placeholder
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            placeholder
        }
        #endif
    }
    
    private var placeholder: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "photo")
                .foregroundColor(.secondary)
        }
    }
}
