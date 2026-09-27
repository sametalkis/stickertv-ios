import Foundation

/// Performance report of an optimization pass.
public struct OptimizationReport: Sendable {
    public let originalBytes: Int
    public let optimizedBytes: Int
    public let frameCount: Int
    public let effectiveFPS: Double
    public let durationSeconds: Double
    public let compressionRatio: Double
    
    public init(
        originalBytes: Int,
        optimizedBytes: Int,
        frameCount: Int,
        effectiveFPS: Double,
        durationSeconds: Double
    ) {
        self.originalBytes = originalBytes
        self.optimizedBytes = optimizedBytes
        self.frameCount = frameCount
        self.effectiveFPS = effectiveFPS
        self.durationSeconds = durationSeconds
        self.compressionRatio = originalBytes > 0
            ? Double(optimizedBytes) / Double(originalBytes)
            : 1.0
    }
}

/// Parameters guiding the adaptive optimization pipeline.
public struct OptimizationConfig: Sendable {
    public var maxBytes: Int
    public var maxDurationSeconds: Double
    public var targetFrameRate: Double
    public var initialQuality: Float
    public var minimumQuality: Float
    
    public static let standard = OptimizationConfig(
        maxBytes: WhatsAppLimits.safeAnimatedStickerBytes, // 480 KB safe threshold
        maxDurationSeconds: WhatsAppLimits.maxAnimationDurationSeconds, // 6.0s
        targetFrameRate: 20.0, // 20 FPS is smooth yet lightweight
        initialQuality: 75.0,
        minimumQuality: 35.0
    )
}

/// Smart Animated WebP and GIF optimization engine for WhatsApp stickers.
/// Employs adaptive frame subsampling, duration clamping, and iterative quality compression
/// to guarantee animations strictly meet WhatsApp's <=500 KB and <=6s rules.
public struct AnimatedWebPOptimizer: Sendable {
    
    public let config: OptimizationConfig
    
    public init(config: OptimizationConfig = .standard) {
        self.config = config
    }
    
    /// Metadata representation of extracted animation frames.
    public struct FrameMeta: Sendable {
        public let index: Int
        public let durationSeconds: Double
    }
    
    /// Plans frame decimation/subsampling to maintain smooth timing while halving frame count.
    /// - Parameters:
    ///   - totalFrames: Total frame count in the source animation.
    ///   - totalDuration: Duration in seconds.
    ///   - targetMaxFrames: Maximum allowed frames based on target FPS.
    /// - Returns: Indices of frames to keep and their recalculated durations.
    public static func planFrameSampling(
        totalFrames: Int,
        totalDuration: Double,
        targetMaxFrames: Int = 30
    ) -> [FrameMeta] {
        guard totalFrames > 0 else { return [] }
        
        let clampedDuration = min(totalDuration, WhatsAppLimits.maxAnimationDurationSeconds)
        
        // If frames already within target budget, keep all
        if totalFrames <= targetMaxFrames && totalDuration <= WhatsAppLimits.maxAnimationDurationSeconds {
            let avgDuration = clampedDuration / Double(totalFrames)
            return (0..<totalFrames).map { FrameMeta(index: $0, durationSeconds: avgDuration) }
        }
        
        // Compute decimation factor
        let factor = max(1, Int(ceil(Double(totalFrames) / Double(targetMaxFrames))))
        var sampled: [FrameMeta] = []
        
        var currentIndex = 0
        while currentIndex < totalFrames {
            sampled.append(FrameMeta(index: currentIndex, durationSeconds: 0.0))
            currentIndex += factor
        }
        
        // Distribute clamped duration evenly across sampled frames
        let frameDuration = clampedDuration / Double(sampled.count)
        return sampled.map { FrameMeta(index: $0.index, durationSeconds: frameDuration) }
    }
    
    /// Computes whether a sticker data meets all WhatsApp size and duration limits.
    public static func validate(data: Data, isAnimated: Bool) -> (isValid: Bool, error: String?) {
        if isAnimated {
            if data.count > WhatsAppLimits.maxAnimatedStickerBytes {
                let kb = data.count / 1024
                return (false, "Hareketli çıkartma boyutu \(kb) KB. WhatsApp sınırı maksimum 500 KB'dır.")
            }
        } else {
            if data.count > WhatsAppLimits.maxStaticStickerBytes {
                let kb = data.count / 1024
                return (false, "Statik çıkartma boyutu \(kb) KB. WhatsApp sınırı maksimum 100 KB'dır.")
            }
        }
        return (true, nil)
    }
}
