//
//  AssetPath.swift
//  iOS-ToolKit
//
//  Created by Srivinayak Chaitanya Eshwa on 12/09/24.
//

import Foundation

public struct AssetPath {
    let name: String
    let fileExtension: String
    let bundle: Bundle
    
    public init(name: String, fileExtension: String, bundle: Bundle = .main) {
        self.name = name
        self.fileExtension = fileExtension
        self.bundle = bundle
    }
    
    var resourcePathString: String? {
        return bundle.path(forResource: name, ofType: fileExtension)
    }
    
    var url: URL? {
        return bundle.url(forResource: name, withExtension: fileExtension)
    }
}
