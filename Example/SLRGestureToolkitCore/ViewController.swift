//
//  ViewController.swift
//  SLRGestureToolkitCore
//
//  Created by eshwavin@gmail.com on 10/21/2024.
//  Copyright (c) 2024 eshwavin@gmail.com. All rights reserved.
//

import UIKit
import SLRGestureToolkitCore

class ViewController: UIViewController {
    
    private let basicExampleButton: UIButton = {
        let button = UIButton()
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.cornerStyle = .medium
        buttonConfiguration.title = String(localized: "Basic Example")
        buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        button.configuration = buttonConfiguration
        return button
    }()
    
    private let boggleGameButton: UIButton = {
        let button = UIButton()
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.cornerStyle = .medium
        buttonConfiguration.title = String(localized: "Boggle Game")
        buttonConfiguration.baseBackgroundColor = .orange
        buttonConfiguration.baseForegroundColor = .white
        buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        button.configuration = buttonConfiguration
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let stackView = UIStackView(arrangedSubviews: [basicExampleButton, boggleGameButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        boggleGameButton.addTarget(self, action: #selector(didTapShowBoggleGame(_:)), for: .touchUpInside)
        basicExampleButton.addTarget(self, action: #selector(didTapShowBasicExample(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapShowBasicExample(_ sender: UIButton) {
        let basicExampleViewController = BasicExampleViewController()
        basicExampleViewController.modalPresentationStyle = .fullScreen
        present(basicExampleViewController, animated: true)
    }

    @objc private func didTapShowBoggleGame(_ sender: UIButton) {
        let boggleHomeViewController = BoggleHomeViewController(gridSize: 5)
        boggleHomeViewController.modalPresentationStyle = .fullScreen
        present(boggleHomeViewController, animated: true)
    }

}

