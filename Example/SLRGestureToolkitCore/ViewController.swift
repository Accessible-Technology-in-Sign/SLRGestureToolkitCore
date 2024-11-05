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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(basicExampleButton)
        
        basicExampleButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            basicExampleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            basicExampleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        basicExampleButton.addTarget(self, action: #selector(didTapShowBasicExample(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapShowBasicExample(_ sender: UIButton) {
        let basicExampleViewController = BasicExampleViewController()
        basicExampleViewController.modalPresentationStyle = .fullScreen
        present(basicExampleViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

