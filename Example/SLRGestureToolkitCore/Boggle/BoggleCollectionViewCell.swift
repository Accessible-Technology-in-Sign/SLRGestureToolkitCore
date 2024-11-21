//
//  BoggleCollectionViewCell.swift
//  SLRGestureToolkitCore_Example
//
//  Created by Srivinayak Chaitanya Eshwa on 21/11/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

final class BoggleCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "BoggleCollectionViewCell"
    
    private let characterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BoggleCollectionViewCell {
    
    private func setup() {
        
        contentView.backgroundColor = .darkGray
        
        contentView.addSubview(characterLabel)
        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            characterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            characterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            characterLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            characterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
    }
    
    func configure(with string: String) {
        characterLabel.text = string
    }
    
    func setHighlighted(_ highlighted: Bool) {
        contentView.backgroundColor = highlighted ? .green : .darkGray
    }
}
