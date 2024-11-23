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
    /// Confidence level of the inferred sign
    public let confidence: Float
    
    /// Label or name of the inferred sign
    public let label: String
}

public struct SignInferenceResult {
    
    /// Time taken to infer the result
    public let inferenceTime: Double
    /// Inferred result(s)
    public let inferences: [SignInference]
}

