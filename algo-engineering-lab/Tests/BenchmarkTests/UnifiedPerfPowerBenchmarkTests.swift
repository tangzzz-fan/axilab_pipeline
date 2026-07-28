import XCTest
@testable import AlgoSwift

/// T13：统一基准入口（FIR / CoreML / Sleep 后处理）。
/// 不阻塞 CI，仅输出可复现数字并追加到 bench-log。
final class UnifiedPerfPowerBenchmarkTests: XCTestCase {

    func testUnifiedPerfSnapshot() throws {
        let fir = try benchmarkFIR()
        let coreml = try benchmarkCoreML()
        let sleep = try benchmarkSleepPostprocess()

        print(
            """
            [T13 unified-bench]
            fir_naive_ms p50=\(fmt(fir.naiveP50)) p95=\(fmt(fir.naiveP95))
            fir_vdsp_ms  p50=\(fmt(fir.vdspP50)) p95=\(fmt(fir.vdspP95)) speedup=\(fmt(fir.speedup))x
            coreml_fp32_infer_ms p50=\(fmt(coreml.p50)) p95=\(fmt(coreml.p95))
            sleep_postprocess_ms p50=\(fmt(sleep.p50)) p95=\(fmt(sleep.p95))
            """
        )
    }

    private func benchmarkFIR() throws -> (naiveP50: Double, naiveP95: Double, vdspP50: Double, vdspP95: Double, speedup: Double) {
        let fs = 25.0
        let n = Int(fs * 8.0)
        let x = (0..<n).map { i in
            let t = Double(i) / fs
            return sin(2 * .pi * 1.2 * t)
        }
        _ = try FIRFilter.filterNaive(x: x)
        _ = try FIRFilter.filterVDSP(x: x)

        var naive: [Double] = []
        var vdsp: [Double] = []
        let rounds = 40
        for _ in 0..<rounds {
            let t0 = CFAbsoluteTimeGetCurrent()
            _ = try FIRFilter.filterNaive(x: x)
            naive.append((CFAbsoluteTimeGetCurrent() - t0) * 1000)

            let t1 = CFAbsoluteTimeGetCurrent()
            _ = try FIRFilter.filterVDSP(x: x)
            vdsp.append((CFAbsoluteTimeGetCurrent() - t1) * 1000)
        }
        let n50 = percentile(naive, 0.50)
        let v50 = percentile(vdsp, 0.50)
        return (n50, percentile(naive, 0.95), v50, percentile(vdsp, 0.95), n50 / max(v50, 1e-9))
    }

    private func benchmarkCoreML() throws -> (p50: Double, p95: Double) {
        #if canImport(CoreML)
        let modelURL = try locate("artifacts/coreml/activity_fp32.mlpackage")
        let x: [Double] = [0.2, -0.1, 0.3, 0.1, 0.0, 0.2, -0.05, 0.12]
        _ = try CoreMLActivityModel.predictProbabilities(modelURL: modelURL, features: x)
        var samples: [Double] = []
        for _ in 0..<30 {
            let t0 = CFAbsoluteTimeGetCurrent()
            _ = try CoreMLActivityModel.predictProbabilities(modelURL: modelURL, features: x)
            samples.append((CFAbsoluteTimeGetCurrent() - t0) * 1000)
        }
        return (percentile(samples, 0.50), percentile(samples, 0.95))
        #else
        return (0, 0)
        #endif
    }

    private func benchmarkSleepPostprocess() throws -> (p50: Double, p95: Double) {
        let prob = [0.80, 0.05, 0.05, 0.05, 0.05]
        let seq = Array(repeating: prob, count: 120)
        _ = try SleepStagingPostprocess.run(probSeq: seq)
        var samples: [Double] = []
        for _ in 0..<40 {
            let t0 = CFAbsoluteTimeGetCurrent()
            _ = try SleepStagingPostprocess.run(probSeq: seq)
            samples.append((CFAbsoluteTimeGetCurrent() - t0) * 1000)
        }
        return (percentile(samples, 0.50), percentile(samples, 0.95))
    }

    private func percentile(_ values: [Double], _ p: Double) -> Double {
        let s = values.sorted()
        let idx = min(s.count - 1, Int(Double(s.count - 1) * p))
        return s[idx]
    }

    private func fmt(_ x: Double) -> String {
        String(format: "%.4f", x)
    }

    private func locate(_ relative: String) throws -> URL {
        var url = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        for _ in 0..<8 {
            let candidate = url.appendingPathComponent(relative)
            if FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
            url.deleteLastPathComponent()
        }
        throw NSError(domain: "UnifiedPerfBenchmark", code: 1)
    }
}
