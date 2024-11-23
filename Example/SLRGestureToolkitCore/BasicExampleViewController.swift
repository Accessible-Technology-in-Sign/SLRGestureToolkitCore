//
//  HomeViewController.swift
//  SLRGestureToolkitCore_Example
//
//  Created by Srivinayak Chaitanya Eshwa on 05/11/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SLRGestureToolkitCore

final class BasicExampleViewController: UIViewController {
    
    private let startButton: UIButton = {
        let button = UIButton()
        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.title = String(localized: "Start Detecting")
        buttonConfiguration.image = UIImage(systemName: "hand.thumbsup")
        buttonConfiguration.imagePadding = 8
        button.configuration = buttonConfiguration
        return button
    }()
    
    private let inferenceLabel: UILabel = {
        let inferenceLabel = UILabel()
        inferenceLabel.text = String(localized: "Press button to detect sign")
        inferenceLabel.textAlignment = .center
        return inferenceLabel
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [startButton, inferenceLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let closeButton = UIButton(type: .close)
    
    private let cameraView = SLRGTKCameraView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        cameraView.isHidden = true
        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        cameraView.delegate = self
        
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12)
        ])
        
        startButton.addTarget(self, action: #selector(didTouchDownInsideStartButton(_:)), for: .touchDown)
        startButton.addTarget(self, action: #selector(didTouchUpStartButton(_:)), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(didTouchUpStartButton(_:)), for: .touchUpOutside)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton(_:)), for: .touchUpInside)
    }
    
    @objc private func didTouchDownInsideStartButton(_ sender: UIButton) {
        cameraView.setupEngine()
        cameraView.fadeIn() {
            self.cameraView.start()
        }
        stackView.fadeOut(modifiesHiddenBehaviour: false)
    }
    
    @objc private func didTouchUpStartButton(_ sender: UIButton) {
        cameraView.detect()
        cameraView.fadeOut()
        stackView.fadeIn(modifiesHiddenBehaviour: false)
        startButton.isEnabled = false
        inferenceLabel.text = String(localized: "Processing")
    }
    
    @objc private func didTapCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }

}

extension BasicExampleViewController: SLRGTKCameraViewDelegate {
    
    func cameraViewDidSetupEngine() {
        print("Did setup engine")
    }
    
    func cameraViewDidBeginInferring() {
        inferenceLabel.text = String(localized: "Inferring")
    }
    
    func cameraViewDidInferSign(_ signInferenceResult: SignInferenceResult) {
        inferenceLabel.text = signInferenceResult.inferences.first?.label
        resetDetectButton()
    }
    
    func cameraViewDidThrowError(_ error: any Error) {
        DispatchQueue.main.async {
            self.inferenceLabel.text = "Error!"
            self.resetDetectButton()
        }
        
        print(error.localizedDescription)
    }
    
    private func resetDetectButton() {
        var buttonConfiguration = startButton.configuration
        buttonConfiguration?.title = String(localized: "Detect Again")
        startButton.configuration = buttonConfiguration
        startButton.isEnabled = true
    }
}


