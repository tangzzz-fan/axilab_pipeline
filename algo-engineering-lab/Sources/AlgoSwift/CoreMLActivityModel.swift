import Foundation

#if canImport(CoreML)
import CoreML

/// 读取 Python 生成的 CoreML `.mlpackage` 并在 Swift 侧执行推理。
public enum CoreMLActivityModel {
    public static func predictProbabilities(
        modelURL: URL,
        features: [Double]
    ) throws -> [Double] {
        guard features.count == 8 else { throw AlgoError.invalidArgument }
        // Python 产出的 .mlpackage 先编译再加载，避免运行时直接读 package 失败。
        let compiledURL = try MLModel.compileModel(at: modelURL)
        let model = try MLModel(contentsOf: compiledURL)

        let inputName = model.modelDescription.inputDescriptionsByName.keys.first ?? "features"
        let outputName = model.modelDescription.outputDescriptionsByName.keys.first ?? "softmax_0"

        let shape = [1, 8] as [NSNumber]
        let inputArray = try MLMultiArray(shape: shape, dataType: .float32)
        for i in 0..<8 {
            inputArray[i] = NSNumber(value: Float(features[i]))
        }
        let provider = try MLDictionaryFeatureProvider(dictionary: [inputName: inputArray])
        let out = try model.prediction(from: provider)
        guard let outArray = out.featureValue(for: outputName)?.multiArrayValue else {
            throw AlgoError.invalidArgument
        }
        let count = outArray.count
        var probs = [Double]()
        probs.reserveCapacity(count)
        for i in 0..<count {
            probs.append(outArray[i].doubleValue)
        }
        return probs
    }
}
#endif
