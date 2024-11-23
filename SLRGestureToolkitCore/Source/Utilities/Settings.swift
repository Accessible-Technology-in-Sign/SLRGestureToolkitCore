//
//  SLRGTKSettings.swift
//  iOS-ToolKit
//
//  Created by Srivinayak Chaitanya Eshwa on 12/09/24.
//

import UIKit
import MediaPipeTasksVision

public struct SLRGTKSettings {
    
    let isContinuous: Bool
    
    let handlandmarkerSettings: HandLandmarkerSettings
    let signInferenceSettings: SignInferenceSettings
    
    public init(handlandmarkerSettings: HandLandmarkerSettings, signInferenceSettings: SignInferenceSettings, isContinuous: Bool = false) {
        self.handlandmarkerSettings = handlandmarkerSettings
        self.signInferenceSettings = signInferenceSettings
        self.isContinuous = isContinuous
    }
    
    public static var defaultSettings: SLRGTKSettings = SLRGTKSettings(
        handlandmarkerSettings: HandLandmarkerSettings(),
        signInferenceSettings: SignInferenceSettings()
    )
}

public struct HandLandmarkerSettings {
    let lineWidth: CGFloat
    let pointRadius: CGFloat
    let pointColor: UIColor
    let pointFillColor: UIColor
    let lineColor: UIColor

    let numHands: Int
    let minHandDetectionConfidence: Float
    let minHandPresenceConfidence: Float
    let minTrackingConfidence: Float
    let modelPath: AssetPath
    let handLandmarkerProcessor: HandLandmarkerProcessor
    
    public init(lineWidth: CGFloat = 2,
         pointRadius: CGFloat = 5,
         pointColor: UIColor = .yellow,
         pointFillColor: UIColor = .red,
         lineColor: UIColor = UIColor(red: 0, green: 127/255.0, blue: 139/255.0, alpha: 1),
         numHands: Int = 1,
         minHandDetectionConfidence: Float = 0.5,
         minHandPresenceConfidence: Float = 0.5,
         minTrackingConfidence: Float = 0.5,
         modelPath: AssetPath = AssetPath(name: "hand_landmarker", fileExtension: "task"),
         handLandmarkerProcessor: HandLandmarkerProcessor = .GPU
     ) {
        self.lineWidth = lineWidth
        self.pointRadius = pointRadius
        self.pointColor = pointColor
        self.pointFillColor = pointFillColor
        self.lineColor = lineColor
        self.numHands = numHands
        self.minHandDetectionConfidence = minHandDetectionConfidence
        self.minHandPresenceConfidence = minHandPresenceConfidence
        self.minTrackingConfidence = minTrackingConfidence
        self.modelPath = modelPath
        self.handLandmarkerProcessor = handLandmarkerProcessor
    }
    
    struct OverlaySettings {
        let lineWidth: CGFloat
        let pointRadius: CGFloat
        let pointColor: UIColor
        let pointFillColor: UIColor
        let lineColor: UIColor
    }
    
    func getOverlaySettings() -> OverlaySettings {
        return OverlaySettings(lineWidth: lineWidth, pointRadius: pointRadius, pointColor: pointColor, pointFillColor: pointFillColor, lineColor: lineColor)
    }
}

public struct SignInferenceSettings {
    
    let numberOfFramesPerInference: Int
    let numberOfPointsPerLandmark: Int
    
    let bufferType: BufferType
    
    let threadCount: Int
    let modelPath: AssetPath
    let labelsPath: AssetPath
    
    public init(numberOfFramesPerInference: Int = 60,
         numberOfPointsPerLandmark: Int = 21,
         threadCount: Int = 1,
         bufferType: BufferType = .defaultType,
         modelPath: AssetPath = AssetPath(name: "model_2", fileExtension: "tflite"),
         labelsPath: AssetPath = AssetPath(name: "signsList", fileExtension: "txt")
    ) {
        self.numberOfFramesPerInference = numberOfFramesPerInference
        self.numberOfPointsPerLandmark = numberOfPointsPerLandmark
        self.bufferType = bufferType
        self.threadCount = threadCount
        self.modelPath = modelPath
        self.labelsPath = labelsPath
    }
    
    public func getBuffer() -> any Buffer {
        return bufferType.getBuffer(
            numberOfFramesPerInference: numberOfFramesPerInference,
            numberOfPointsPerLandmark: numberOfPointsPerLandmark
        )
    }
}
    
