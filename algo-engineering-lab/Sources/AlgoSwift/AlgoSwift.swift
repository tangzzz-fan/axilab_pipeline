import Foundation
import AlgoC

/// 将 C 层 `ALGO_ERR_*` 翻译成 Swift 可 `throw` 的错误（见 docs/04）。
public enum AlgoError: Error, Equatable {
    case empty
    case tooShort
    case nonFinite
    case nullPointer
    case invalidArgument
    case unknown(code: Int32)

    public init(algoCode code: Int32) {
        switch code {
        case Int32(ALGO_OK):
            preconditionFailure("ALGO_OK is not an error")
        case Int32(ALGO_ERR_EMPTY): self = .empty
        case Int32(ALGO_ERR_TOO_SHORT): self = .tooShort
        case Int32(ALGO_ERR_NON_FINITE): self = .nonFinite
        case Int32(ALGO_ERR_NULL_POINTER): self = .nullPointer
        case Int32(ALGO_ERR_INVALID_ARG): self = .invalidArgument
        default: self = .unknown(code: code)
        }
    }
}

public enum AlgoVersion {
    /// 读取 AlgoC 编译进进程的版本（冒烟：确认链接正确）。
    public static func current() throws -> (major: Int32, minor: Int32, patch: Int32) {
        var major: Int32 = 0
        var minor: Int32 = 0
        var patch: Int32 = 0
        let code = algo_version(&major, &minor, &patch)
        guard code == ALGO_OK else { throw AlgoError(algoCode: code) }
        return (major, minor, patch)
    }
}

/// HRV 时域结果（ms / 百分点），与 golden `expected` 字段对齐。
public struct HRVTimeDomainResult: Equatable {
    public var sdnnMs: Double
    public var rmssdMs: Double
    public var pnn50: Double
    public var meanRrMs: Double
}

public enum HRVTimeDomain {
    /**
     计算 SDNN / RMSSD / pNN50。

     - Important: 使用连续 `Double` 缓冲零拷贝传给 C（docs/04），
       不要在热路径上逐元素装箱。
     - Note: 单位必须是 **毫秒**；本 case 不做伪差校正。
     */
    public static func compute(rrMs: [Double]) throws -> HRVTimeDomainResult {
        // 空数组：走 C 的 EMPTY，保持跨语言错误语义一致
        if rrMs.isEmpty {
            throw AlgoError.empty
        }

        var sdnn = 0.0
        var rmssd = 0.0
        var pnn50 = 0.0
        var mean = 0.0

        // withUnsafeBufferPointer：把 Swift Array 的连续存储直接交给 C
        let code: Int32 = rrMs.withUnsafeBufferPointer { buf in
            guard let base = buf.baseAddress else {
                return Int32(ALGO_ERR_NULL_POINTER)
            }
            return algo_hrv_time_domain(
                base,
                buf.count,
                &sdnn,
                &rmssd,
                &pnn50,
                &mean
            )
        }

        guard code == ALGO_OK else { throw AlgoError(algoCode: code) }
        return HRVTimeDomainResult(
            sdnnMs: sdnn,
            rmssdMs: rmssd,
            pnn50: pnn50,
            meanRrMs: mean
        )
    }
}
