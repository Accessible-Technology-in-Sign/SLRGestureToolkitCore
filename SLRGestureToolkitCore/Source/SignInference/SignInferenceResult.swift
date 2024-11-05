//
//  InferenceResult.swift
//  iOS-ToolKit
//
//  Created by Srivinayak Chaitanya Eshwa on 12/09/24.
//

import Foundation

/**
 Stores one formatted inference.
 */
public struct SignInference {
    public let confidence: Float
    public let label: String
}

public struct SignInferenceResult {
    public let inferenceTime: Double
    public let inferences: [SignInference]
}

