// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StickerTV",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "StickerCore", targets: ["StickerCore"]),
        .library(name: "SevenTVSource", targets: ["SevenTVSource"]),
        .library(name: "WhatsAppEngine", targets: ["WhatsAppEngine"]),
        .library(name: "StickerAppCore", targets: ["StickerAppCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.14.6"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.19.0")
    ],
    targets: [
        // MARK: - Core Domain & Multi-Source Abstraction
        .target(
            name: "StickerCore",
            dependencies: [],
            path: "Sources/StickerCore"
        ),
        .testTarget(
            name: "StickerCoreTests",
            dependencies: ["StickerCore"],
            path: "Tests/StickerCoreTests"
        ),

        // MARK: - SevenTV v4 Provider
        .target(
            name: "SevenTVSource",
            dependencies: ["StickerCore"],
            path: "Sources/SevenTVSource"
        ),
        .testTarget(
            name: "SevenTVSourceTests",
            dependencies: ["SevenTVSource", "StickerCore"],
            path: "Tests/SevenTVSourceTests"
        ),

        // MARK: - WhatsApp Engine (Validation, Optimization, Export)
        .target(
            name: "WhatsAppEngine",
            dependencies: [
                "StickerCore",
                .product(name: "SDWebImageWebPCoder", package: "SDWebImageWebPCoder")
            ],
            path: "Sources/WhatsAppEngine"
        ),
        .testTarget(
            name: "WhatsAppEngineTests",
            dependencies: ["WhatsAppEngine", "StickerCore"],
            path: "Tests/WhatsAppEngineTests"
        ),

        // MARK: - App UI & State Management
        .target(
            name: "StickerAppCore",
            dependencies: [
                "StickerCore",
                "SevenTVSource",
                "WhatsAppEngine",
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "SDWebImageWebPCoder", package: "SDWebImageWebPCoder")
            ],
            path: "Sources/StickerAppCore"
        )
    ]
)
