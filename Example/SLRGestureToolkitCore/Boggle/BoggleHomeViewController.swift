//
//  BoggleHomeViewController.swift
//  iOS-ToolKit
//
//  Created by Unnathi Utpal Kumar, Kellen Madigan, and David Nuthakki.
//

import UIKit
import SLRGestureToolkitCore

final class BoggleHomeViewController: UIViewController {
    
    private let gridSize: Int
    private var currentWord: String = ""
    
    private let game: BoggleGame
    
    private let inferenceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "When You See a Word Sign It!"
        label.textColor = .white
        return label
    }()
    
    private let signButton: UIButton = {
        let button = UIButton()
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.cornerStyle = .medium
        
        buttonConfiguration.attributedTitle = AttributedString("Sign", attributes: AttributeContainer([.font: UIFont.boldSystemFont(ofSize: 24)]))

        buttonConfiguration.baseBackgroundColor = .orange
        buttonConfiguration.baseForegroundColor = .white
        buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 16)
        
        button.configuration = buttonConfiguration
        return button
    }()
    
    private let cameraView = SLRGTKCameraView()
    private let closeButton = UIButton(type: .close)
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(BoggleCollectionViewCell.self, forCellWithReuseIdentifier: BoggleCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    init(words: Set<String> = ["DOG", "CAT", "APPLE", "JUMP", "QUIET"], gridSize: Int) {
        self.game = BoggleGame(gridSize: gridSize, words: words)
        self.gridSize = gridSize
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .black
        
        setupCameraView()
        setupCloseButton()
        
        setupInferenceLabel()
        setupCollectionView()
        setupSignButton()
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12)
        ])
        closeButton.addTarget(self, action: #selector(didTapCloseButton(_:)), for: .touchUpInside)
    }
    
    private func setupCameraView() {
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
    }
        
    private func setupInferenceLabel() {
        view.addSubview(inferenceLabel)
        inferenceLabel.translatesAutoresizingMaskIntoConstraints = false
        inferenceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        inferenceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        inferenceLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20).isActive = true
    }
    
    private func setupSignButton() {
        
        signButton.addTarget(self, action: #selector(didTouchDownInsideStartButton(_:)), for: .touchDown)
        signButton.addTarget(self, action: #selector(didTouchUpStartButton(_:)), for: .touchUpInside)
        
        view.addSubview(signButton)
        signButton.translatesAutoresizingMaskIntoConstraints = false
        signButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        signButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20).isActive = true
        signButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        signButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.topAnchor.constraint(equalTo: inferenceLabel.bottomAnchor, constant: 20),
            collectionView.widthAnchor.constraint(equalTo: collectionView.heightAnchor, multiplier: 1, constant: -10)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc private func didTouchDownInsideStartButton(_ sender: UIButton) {
        cameraView.setupEngine()
        cameraView.fadeIn() {
            self.cameraView.start()
        }
        collectionView.fadeOut(modifiesHiddenBehaviour: false)
    }
    
    @objc private func didTouchUpStartButton(_ sender: UIButton) {
        cameraView.detect()
        cameraView.fadeOut()
        collectionView.fadeIn(modifiesHiddenBehaviour: false)
        signButton.isEnabled = false
        inferenceLabel.text = String(localized: "Processing")
    }
    
    @objc private func didTapCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func submitWord() {
        //highlightFoundWord()
        if let wordPositions = game.getDictionary()[currentWord] {
            let alertValid = UIAlertController(
                title: "Well done!",
                message: "The word '\(currentWord)' is present.",
                preferredStyle: .alert)
            alertValid.addAction(UIAlertAction(title: "GREAT", style: .default, handler: {_ in self.highlightWordPositions(wordPositions)
            }))
            present(alertValid, animated: true, completion: nil)
            inferenceLabel.text = "Find Another Word!"
        }   else {
            let alertInvalid = UIAlertController(
                title: "Not quite",
                message: "The word '\(currentWord)' is not present.",
                preferredStyle: .alert
            )
            alertInvalid.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertInvalid, animated: true, completion: nil)
            inferenceLabel.text = "Try Again!"
            currentWord = ""
        }
    }
    
    private func highlightWordPositions(_ positions: [(Int, Int)]) {
        for (item, section) in positions {
            let indexPath = IndexPath(item: item, section: section)
            if let cell = collectionView.cellForItem(at: indexPath) as? BoggleCollectionViewCell {
                UIView.animate(withDuration: 0.1) {
                    cell.setHighlighted(true)
                }
            }
        }
    }
}

extension BoggleHomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gridSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoggleCollectionViewCell.reuseIdentifier, for: indexPath) as? BoggleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let string = game.board[indexPath.row][indexPath.section]
        cell.configure(with: string)
        return cell
    }
}

extension BoggleHomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = view.bounds.width - 40 - 40
        
        let cellSize: CGFloat = screenWidth / CGFloat(gridSize)
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
}

extension BoggleHomeViewController: SLRGTKCameraViewDelegate {
    
    func cameraViewDidSetupEngine() {
        print("Did setup engine")
    }
    
    func cameraViewDidBeginInferring() {
        inferenceLabel.text = String(localized: "Inferring")
    }
    
    func cameraViewDidInferSign(_ signInferenceResult: SignInferenceResult) {
        inferenceLabel.text = "Word : \(signInferenceResult.inferences.first!.label)"
        currentWord = signInferenceResult.inferences.first!.label.uppercased()
        submitWord()
        resetDetectButton()
    }
    
    func cameraViewDidThrowError(_ error: any Error) {
        DispatchQueue.main.async {
            self.inferenceLabel.text = "Sign again"
            self.resetDetectButton()
            self.currentWord = ""
        }
        
        print(error.localizedDescription)
    }
    
    private func resetDetectButton() {
        var buttonConfiguration = signButton.configuration
        signButton.configuration = buttonConfiguration
        signButton.isEnabled = true
    }
}
