import Foundation
import UIKit
import Vision
import AVFoundation

@MainActor
class AICameraViewModel: NSObject, ObservableObject {
    @Published var isCameraActive = false
    @Published var detectedFace = false
    @Published var capturedImage: UIImage?
    @Published var detectionMessage = "请将脸部对准摄像头"
    
    // 将这些属性从 MainActor 隔离，因为它们需要在后台队列中访问
    nonisolated private let captureSession = AVCaptureSession()
    nonisolated private let videoOutput = AVCaptureVideoDataOutput()
    nonisolated private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    var onCapture: ((Data?) -> Void)?
    
    func startCamera() {
        #if targetEnvironment(simulator)
        
        DispatchQueue.main.async { [weak self] in
            self?.isCameraActive = true
            self?.detectedFace = true
            self?.detectionMessage = "模拟器模式：点击拍照"
            
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
                    self?.detectionMessage = "请在设置中允许相机权限"
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
        guard detectedFace, let image = capturedImage else { return }
        
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
            }
        }
    }
    
    private func detectFace(in image: CIImage) {
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let observations = request.results as? [VNFaceObservation],
                  !observations.isEmpty else {
                DispatchQueue.main.async {
                    self?.detectedFace = false
                    self?.detectionMessage = "请将脸部对准摄像头"
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.detectedFace = true
                self?.detectionMessage = "检测到人脸，点击拍照打卡"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        try? handler.perform([request])
    }
}

extension AICameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        Task { @MainActor in
            detectFace(in: ciImage)
        }
        
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            Task { @MainActor in
                self.capturedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .leftMirrored)
            }
        }
    }
}