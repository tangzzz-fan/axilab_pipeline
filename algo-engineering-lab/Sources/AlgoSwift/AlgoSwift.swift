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
            // 调用方应先判断 OK；走到这里说明用法有误
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

/// Swift 封装层入口示例：隐藏指针细节，对外只暴露 Result/throws。
public enum AlgoVersion {
    /// 读取 AlgoC 编译进进程的版本（用于 Parity 冒烟，确认链接正确）。
    public static func current() throws -> (major: Int32, minor: Int32, patch: Int32) {
        var major: Int32 = 0
        var minor: Int32 = 0
        var patch: Int32 = 0
        // 调用方（Swift）分配栈上变量；C 只写入——符合「谁分配谁释放」
        let code = algo_version(&major, &minor, &patch)
        guard code == ALGO_OK else { throw AlgoError(algoCode: code) }
        return (major, minor, patch)
    }
}
