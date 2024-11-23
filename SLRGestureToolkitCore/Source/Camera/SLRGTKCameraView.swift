//
//  CameraView.swift
//  iOS-ToolKit
//
//  Created by Srivinayak Chaitanya Eshwa on 09/09/24.
//

import UIKit
import MediaPipeTasksVision

public protocol SLRGTKCameraViewDelegate: AnyObject {
    /// Called when SLRGTKCameraView has started to infer the sign. Sign inference is triggered by `SLRGTKCameraView.detect()`
    func cameraViewDidBeginInferring()
    
    /// Called when the engine has been setup. Engine setup is triggered by `SLRGTKCameraView.setupEngine()`
    func cameraViewDidSetupEngine()
    
    /// Delivers the inferred result
    /// - Parameter signInferenceResult: Inferred result
    func cameraViewDidInferSign(_ signInferenceResult: SignInferenceResult)
    
    /// Called when any error occurs
    /// - Parameter error: The error that occured
    func cameraViewDidThrowError(_ error: Error)
}

/// SLRGTKCameraView contains the Camera and the Engine for Sign Language Recognition
public final class SLRGTKCameraView: UIView {
    
    /// The object that acts as the delegate of the Camera View
    /// The delegate must adopt the SLRGTKCameraViewDelegate protocol. The delegate object is responsible for listening to updates provided by the SLRGTKCameraView
    public weak var delegate: SLRGTKCameraViewDelegate?
    
    private lazy var buffer: any Buffer = settings.signInferenceSettings.getBuffer()
    
    private let handLandmarkerServiceQueue = DispatchQueue(
        label: "com.wavinDev.cameraView.handLandmarkerServiceQueue",
        attributes: .concurrent)
    
    private let backgroundQueue = DispatchQueue(label: "com.wavinDev.cameraView.backgroundQueue")
    
    private let overlayView = OverlayView()
    
    private var settings: SLRGTKSettings = .defaultSettings
    
    private lazy var resumeButton: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "Resume"), for: .normal)
        button.addTarget(self, action: #selector(didTapResume(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cameraUnavailableLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = String(localized: "Camera Unavailable")
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private lazy var cameraFeedService = CameraFeedService(previewView: self)
    
    private var _handLandmarkerService: HandLandmarkerService?
    private var handLandmarkerService: HandLandmarkerService? {
        get {
            handLandmarkerServiceQueue.sync {
                return self._handLandmarkerService
            }
        }
        set {
            handLandmarkerServiceQueue.async(flags: .barrier) {
                self._handLandmarkerService = newValue
            }
        }
    }
    
    private var signInferenceService: SignInferenceService?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        self.settings = .defaultSettings
        super.init(coder: coder)
        setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        cameraFeedService.updateVideoPreviewLayer(toFrame: bounds)
    }
    
    public func setupEngine() {
        setupSignInferenceService()
        configureBuffer()
        delegate?.cameraViewDidSetupEngine()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        overlayView.backgroundColor = .clear
        
        cameraFeedService.delegate = self
        
        addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // TODO: Resume and Camera Unavailable

    }
    
    private func configureBuffer() {
        buffer = settings.signInferenceSettings.getBuffer()
    }
    
    private func setupSignInferenceService() {
        do {
            signInferenceService = try SignInferenceService(settings: settings.signInferenceSettings)
        } catch {
            delegate?.cameraViewDidThrowError(error)
        }
    }
}

// MARK: - Settings
extension SLRGTKCameraView {
    
    private func changeSettings(_ settings: SLRGTKSettings) {
        self.settings = settings
        reconfigureEngine()
    }
    
    private func reconfigureEngine() {
        clearAndInitializeHandLandmarkerService()
        configureBuffer()
        setupSignInferenceService()
    }
}

// MARK: - Start
extension SLRGTKCameraView {
    
    /// Begins the gesture recognition process by activating the camera feed. The camera is always the front camera in wide angle if supported.
    public func start() {
        initializeHandLandmarkerServiceOnSessionResumption()
        cameraFeedService.startLiveCameraSession { [weak self] cameraConfiguration in
            DispatchQueue.main.async {
                switch cameraConfiguration {
                case .failed:
                    self?.delegate?.cameraViewDidThrowError(CameraError.configurationFailed)
                case .permissionDenied:
                    self?.delegate?.cameraViewDidThrowError(CameraError.permissionDenied)
                default:
                    break
                }
            }
        }
    }
    
    private func initializeHandLandmarkerServiceOnSessionResumption() {
        clearAndInitializeHandLandmarkerService()
    }
    
    private func clearAndInitializeHandLandmarkerService() {
        handLandmarkerService = nil
        do {
            handLandmarkerService = try HandLandmarkerService(
                modelPath: settings.handlandmarkerSettings.modelPath.resourcePathString,
                numHands: settings.handlandmarkerSettings.numHands,
                minHandDetectionConfidence: settings.handlandmarkerSettings.minHandDetectionConfidence,
                minHandPresenceConfidence: settings.handlandmarkerSettings.minHandPresenceConfidence,
                minTrackingConfidence: settings.handlandmarkerSettings.minTrackingConfidence,
                delegate: settings.handlandmarkerSettings.handLandmarkerProcessor,
                resultsDelegate: self
            )
        } catch {
            delegate?.cameraViewDidThrowError(error)
        }
    }
}

// MARK: - Stop
extension SLRGTKCameraView {
    
    /// Stops the camera feed and clears any data stored from the session
    func stop() {
        cameraFeedService.stopSession()
        clearhandLandmarkerServiceOnSessionInterruption()
        buffer.clear(keepingCapacity: false)
    }
    
    private func clearhandLandmarkerServiceOnSessionInterruption() {
        handLandmarkerService = nil
    }
}

// MARK: - Detection
extension SLRGTKCameraView {
    
    /// Triggers the actual detection and inference of sign gestures based on captured camera input.
    public func detect() {
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.cameraViewDidBeginInferring()
                if !strongSelf.settings.isContinuous {
                    strongSelf.stop()
                }
            }
            
            do {
                let inferenceData = try strongSelf.buffer.getInferenceData()
                
                if let inferenceResults = strongSelf.signInferenceService?.runModel(using: inferenceData) {
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.delegate?.cameraViewDidInferSign(inferenceResults)
                    }
                }
            } catch {
                strongSelf.delegate?.cameraViewDidThrowError(error)
            }
        }
    }
}

// MARK: - Resume Interrupted Session
extension SLRGTKCameraView {
    @objc private func didTapResume(_ sender: UIButton) {
        cameraFeedService.resumeInterruptedSession {[weak self] isSessionRunning in
            if isSessionRunning {
                self?.resumeButton.isHidden = true
                self?.cameraUnavailableLabel.isHidden = true
                self?.initializeHandLandmarkerServiceOnSessionResumption()
            }
        }
    }
}

extension SLRGTKCameraView: CameraFeedServiceDelegate {
    func didOutput(sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation) {
        let currentTimeMs = Date().timeIntervalSince1970 * 1000
        // Pass the pixel buffer to mediapipe
        
        backgroundQueue.async { [weak self] in
            self?.handLandmarkerService?.detectAsync(
                sampleBuffer: sampleBuffer,
                orientation: orientation,
                timeStamps: Int(currentTimeMs)
            )
        }
    }
    
    // MARK: Session Handling Alerts
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        // Updates the UI when session is interupted.
        if resumeManually {
            resumeButton.isHidden = false
        } else {
            cameraUnavailableLabel.isHidden = false
        }
        clearhandLandmarkerServiceOnSessionInterruption()
    }
    
    func sessionInterruptionEnded() {
        // Updates UI once session interruption has ended.
        cameraUnavailableLabel.isHidden = true
        resumeButton.isHidden = true
        initializeHandLandmarkerServiceOnSessionResumption()
    }
    
    func didEncounterSessionRuntimeError() {
        // Handles session run time error by updating the UI and providing a button if session can be
        // manually resumed.
        resumeButton.isHidden = false
        clearhandLandmarkerServiceOnSessionInterruption()
    }
    
}

extension SLRGTKCameraView: HandLandmarkerServiceLiveStreamDelegate {
    func handLandmarkerService(_ handLandmarkerService: HandLandmarkerService, 
                               didFinishDetection result: HandLandmarkerResultBundle?,
                               error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            guard let handLandmarkerResult = result?.handLandmarkerResults.first as? HandLandmarkerResult else { return
            }
            
            if !handLandmarkerResult.landmarks.isEmpty {
                strongSelf.buffer.addItem(handLandmarkerResult)
            }
            
            let imageSize = strongSelf.cameraFeedService.videoResolution
            let handOverlays = OverlayView.handOverlays(
                fromMultipleHandLandmarks: handLandmarkerResult.landmarks,
                inferredOnImageOfSize: imageSize,
                ovelayViewSize: strongSelf.overlayView.bounds.size,
                imageContentMode: strongSelf.overlayView.imageContentMode,
                andOrientation: UIImage.Orientation.from(deviceOrientation: UIDevice.current.orientation)
            )
            strongSelf.overlayView.draw(
                handOverlays: handOverlays,
                inBoundsOfContentImageOfSize: imageSize,
                imageContentMode: strongSelf.cameraFeedService.videoGravity.contentMode
            )
        }
    }
}
