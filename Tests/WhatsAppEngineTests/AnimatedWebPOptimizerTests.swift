import XCTest
@testable import WhatsAppEngine

final class AnimatedWebPOptimizerTests: XCTestCase {
    
    func testPlanFrameSamplingClampsDuration() {
        // If an animation is 10 seconds long with 60 frames
        let sampling = AnimatedWebPOptimizer.planFrameSampling(
            totalFrames: 60,
            totalDuration: 10.0,
            targetMaxFrames: 30
        )
        
        XCTAssertLessThanOrEqual(sampling.count, 30)
        let totalRecalculatedDuration = sampling.reduce(0.0) { $0 + $1.durationSeconds }
        XCTAssertEqual(totalRecalculatedDuration, WhatsAppLimits.maxAnimationDurationSeconds, accuracy: 0.001)
    }
    
    func testValidationRejectsOversizedAnimatedSticker() {
        let oversizedData = Data(count: WhatsAppLimits.maxAnimatedStickerBytes + 1024)
        let (isValid, error) = AnimatedWebPOptimizer.validate(data: oversizedData, isAnimated: true)
        XCTAssertFalse(isValid)
        XCTAssertNotNil(error)
    }
    
    func testValidationAcceptsCompliantAnimatedSticker() {
        let validData = Data(count: WhatsAppLimits.safeAnimatedStickerBytes)
        let (isValid, error) = AnimatedWebPOptimizer.validate(data: validData, isAnimated: true)
        XCTAssertTrue(isValid)
        XCTAssertNil(error)
    }
    
    func testCanvasAspectFitCalculation() {
        let original = CGSize(width: 128, height: 64) // 2:1 aspect ratio
        let target = CGSize(width: 512, height: 512)
        let margin: CGFloat = 16.0
        
        let rect = CanvasResizer.aspectFitRect(originalSize: original, targetSize: target, margin: margin)
        
        // Available width and height: 512 - 32 = 480
        // Scaled width should be 480, height should be 240
        XCTAssertEqual(rect.width, 480.0, accuracy: 1.0)
        XCTAssertEqual(rect.height, 240.0, accuracy: 1.0)
        XCTAssertEqual(rect.minX, 16.0, accuracy: 1.0)
        XCTAssertEqual(rect.minY, 136.0, accuracy: 1.0) // (512 - 240) / 2 = 136
    }
}
