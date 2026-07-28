import XCTest
@testable import AlgoSwift

#if canImport(CoreML)
final class CoreMLModelUsageParityTests: XCTestCase {
    func testSwiftCanLoadAndRunPythonGeneratedModel() throws {
        let modelURL = try Self.locate("artifacts/coreml/activity_fp32.mlpackage")
        let reportURL = try Self.locate("golden/coreml_quant/compare_report.json")

        let reportData = try Data(contentsOf: reportURL)
        let report = try JSONSerialization.jsonObject(with: reportData) as? [String: Any]
        let preprocess = report?["preprocess"] as? [String: Any]
        let mean = (preprocess?["mean"] as? [Double]) ?? []
        let scale = (preprocess?["scale"] as? [Double]) ?? []
        XCTAssertEqual(mean.count, 8)
        XCTAssertEqual(scale.count, 8)

        // raw 特征 -> 使用 Python 报告里的 scaler 参数归一化，确保 Swift 与 Python 同口径
        let raw: [Double] = [0.1, -0.2, 0.3, 0.1, -0.1, 0.2, 0.0, 0.05]
        let scaled = zip(zip(raw, mean), scale).map { (pair, s) in
            let (x, m) = pair
            return (x - m) / s
        }

        let probs = try CoreMLActivityModel.predictProbabilities(modelURL: modelURL, features: scaled)
        XCTAssertEqual(probs.count, 3)
        XCTAssertTrue(probs.allSatisfy { $0.isFinite })
        let sum = probs.reduce(0, +)
        XCTAssertEqual(sum, 1.0, accuracy: 1e-3)
        let top = probs.enumerated().max(by: { $0.element < $1.element })?.offset ?? -1
        XCTAssertTrue((0..<3).contains(top))
    }

    private static func locate(_ relative: String) throws -> URL {
        var url = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        for _ in 0..<8 {
            let candidate = url.appendingPathComponent(relative)
            if FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
            url.deleteLastPathComponent()
        }
        XCTFail("cannot locate \(relative)")
        throw NSError(domain: "CoreMLModelUsage", code: 1)
    }
}
#else
final class CoreMLModelUsageParityTests: XCTestCase {
    func testSkipWhenCoreMLUnavailable() throws {
        throw XCTSkip("CoreML unavailable on this platform")
    }
}
#endif
