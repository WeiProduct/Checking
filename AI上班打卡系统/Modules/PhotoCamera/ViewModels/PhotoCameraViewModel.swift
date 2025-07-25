import Foundation
import UIKit
import AVFoundation

@MainActor
class PhotoCameraViewModel: NSObject, ObservableObject {
    @Published var isCameraActive = false
    @Published var photoReady = false
    @Published var capturedImage: UIImage?
    @Published var statusMessage = "Position yourself for photo"
    
    // Non-isolated properties for background queue access
    nonisolated private let captureSession = AVCaptureSession()
    nonisolated private let videoOutput = AVCaptureVideoDataOutput()
    nonisolated private let sessionQueue = DispatchQueue(label: "photo.camera.session.queue")
    
    var onCapture: ((Data?) -> Void)?
    
    func startCamera() {
        #if targetEnvironment(simulator)
        // Simulator mode
        DispatchQueue.main.async { [weak self] in
            self?.isCameraActive = true
            self?.photoReady = true
            self?.statusMessage = "Simulator mode: Tap to capture"
            
            if let image = UIImage(systemName: "person.circle.fill") {
                self?.capturedImage = image
            }
        }
        #else
        requestCameraPermission { [weak self] granted in
            if granted {
                self?.setupCamera()
            } else {
                DispatchQueue.main.async {
                    self?.statusMessage = "Camera permission required"
                }
            }
        }
        #endif
    }
    
    func stopCamera() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
        Task { @MainActor in
            self.isCameraActive = false
        }
    }
    
    func capturePhoto() {
        guard photoReady, let image = capturedImage else { return }
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            onCapture?(imageData)
        }
    }
    
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let captureSession = self.captureSession
            let videoOutput = self.videoOutput
            
            captureSession.beginConfiguration()
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                return
            }
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            captureSession.commitConfiguration()
            captureSession.startRunning()
            
            Task { @MainActor in
                self.isCameraActive = true
                self.statusMessage = "Ready to take photo"
                // Allow photo capture after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.photoReady = true
                }
            }
        }
    }
}

extension PhotoCameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            Task { @MainActor in
                self.capturedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .leftMirrored)
            }
        }
    }
}