//
//  Buffer.swift
//  iOS-ToolKit
//
//  Created by Srivinayak Chaitanya Eshwa on 11/09/24.
//

import Foundation
import MediaPipeTasksVision

public enum BufferType {
    case defaultType
    case custom(buffer: Buffer)
    
    func getBuffer(numberOfFramesPerInference: Int, numberOfPointsPerLandmark: Int) -> any Buffer {
        switch self {
        case .defaultType:
            return DefaultBuffer(
                numberOfFramesPerInference: numberOfFramesPerInference,
                numberOfPointsPerLandmark: numberOfPointsPerLandmark
            )
            
        case .custom(let buffer):
            return buffer
        }
    }
}

public protocol Buffer {
    var items: [HandLandmarkerResult] { get }
    func addItem(_ item: HandLandmarkerResult)
    func clear(keepingCapacity: Bool)
    func getInferenceData() throws -> [Float]
}

public extension Buffer {
    func clear(keepingCapacity: Bool = false) {
        clear(keepingCapacity: keepingCapacity)
    }
}

final class DefaultBuffer: Buffer {
    
    private let bufferQueue = DispatchQueue(label: "com.wavinDev.Buffer", qos: .background, attributes: .concurrent)
    
    private var _items: [HandLandmarkerResult] = []
    private let numberOfFramesPerInference: Int
    private let numberOfPointsPerLandmark: Int
    
    var items: [HandLandmarkerResult] {
        bufferQueue.sync {
            return _items.suffix(numberOfFramesPerInference)
        }
    }
    
    init(numberOfFramesPerInference: Int, numberOfPointsPerLandmark: Int) {
        self.numberOfFramesPerInference = numberOfFramesPerInference
        self.numberOfPointsPerLandmark = numberOfPointsPerLandmark
    }
    
    func addItem(_ item: HandLandmarkerResult) {
        bufferQueue.async(flags: .barrier) {
            self._items.append(item)
        }
    }
    
    func clear(keepingCapacity: Bool = false) {
        bufferQueue.async(flags: .barrier) {
            self._items.removeAll(keepingCapacity: keepingCapacity)
        }
    }
    
    func getInferenceData() throws -> [Float] {
        var handLandmarks = items
        var inferenceData: [Float] = []
        
        guard !handLandmarks.isEmpty else {
            throw DependencyError.noLandmarks
        }
        
        if handLandmarks.count < numberOfFramesPerInference {
            let midPoint = handLandmarks.count / 2
            
            for _ in 0 ..< (numberOfFramesPerInference - handLandmarks.count) {
                handLandmarks.append(handLandmarks[midPoint])
            }
            
        }
        
        try handLandmarks.forEach { landmark in
            guard let normalizedLandmarks = landmark.landmarks.first,
                  normalizedLandmarks.count == numberOfPointsPerLandmark else {
                throw DependencyError.landmarkStructure
            }
            
            for i in 0 ..< numberOfPointsPerLandmark {
                inferenceData.append(normalizedLandmarks[i].x)
                inferenceData.append(normalizedLandmarks[i].y)
            }
        }
        
        return inferenceData

    }
    
}
