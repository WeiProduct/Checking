import SwiftUI
import AVFoundation

struct PhotoCameraView: View {
    @StateObject private var viewModel = PhotoCameraViewModel()
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
                            Image(systemName: viewModel.photoReady ? "checkmark.circle.fill" : "camera.circle")
                                .font(.title)
                                .foregroundColor(viewModel.photoReady ? .green : .yellow)
                            
                            Text(viewModel.statusMessage)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(15)
                        
                        Button(action: captureAndDismiss) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.photoReady ? Color.green : Color.gray)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(!viewModel.photoReady)
                        .padding(.bottom, 50)
                    }
                } else {
                    ProgressView("Loading camera...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
            }
            .navigationTitle("Photo Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

// CameraPreviewView is already defined in AICameraView.swift