import SwiftUI
import StickerCore

/// Reusable asynchronous image view for displaying emote previews.
public struct AsyncEmoteImageView: View {
    public let url: URL?
    public let contentMode: ContentMode
    
    public init(url: URL?, contentMode: ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }
    
    public var body: some View {
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
                    ZStack {
                        Color(.systemGray5)
                        Image(systemName: "photo.badge.exclamationmark")
                            .foregroundColor(.secondary)
                    }
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            ZStack {
                Color(.systemGray5)
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
            }
        }
    }
}
