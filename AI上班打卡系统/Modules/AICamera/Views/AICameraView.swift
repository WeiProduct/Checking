import SwiftUI
import AVFoundation

struct AICameraView: View {
    @StateObject private var viewModel = AICameraViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let onCapture: (Data?) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isCameraActive {
                    CameraPreviewView(image: viewModel.capturedImage)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: viewModel.detectedFace ? "face.smiling.fill" : "face.dashed")
                                .font(.title)
                                .foregroundColor(viewModel.detectedFace ? .green : .yellow)
                            
                            Text(viewModel.detectionMessage)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(15)
                        
                        Button(action: captureAndDismiss) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.detectedFace ? Color.green : Color.gray)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(!viewModel.detectedFace)
                        .padding(.bottom, 50)
                    }
                } else {
                    ProgressView("正在启动摄像头...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.onCapture = onCapture
                viewModel.startCamera()
            }
            .onDisappear {
                viewModel.stopCamera()
            }
        }
    }
    
    private func captureAndDismiss() {
        viewModel.capturePhoto()
        dismiss()
    }
}

struct CameraPreviewView: View {
    let image: UIImage?
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Color.black
        }
    }
}