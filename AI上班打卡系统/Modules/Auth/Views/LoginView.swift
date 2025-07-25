import SwiftUI

struct LoginView: View {
    @State private var employeeId = ""
    @State private var password = ""
    @State private var showingFaceLogin = false
    @State private var isLoggingIn = false
    @State private var showingMainApp = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingTestAccounts = false
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    
                    VStack(spacing: 20) {
                        Image(systemName: "faceid")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("login.welcome".localized())
                            .font(.largeTitle)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 60)
                    
                    
                    VStack(spacing: 20) {
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            TextField("login.employeeId".localized(), text: $employeeId)
                                .textFieldStyle(PlainTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            SecureField("login.password".localized(), text: $password)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        
                        Button(action: performLogin) {
                            if isLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("login.button".localized())
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            (employeeId.isEmpty || password.isEmpty) ? 
                            Color.gray : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(employeeId.isEmpty || password.isEmpty || isLoggingIn)
                        
                        
                        Button(action: { showingFaceLogin = true }) {
                            HStack {
                                Image(systemName: "face.smiling")
                                Text("login.faceLogin".localized())
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    
                    VStack(spacing: 12) {
                        Text("login.firstTime".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("login.forgotPassword".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // 测试账号提示
                        VStack(spacing: 12) {
                            Text("Test Accounts")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            
                            // Show detailed account info button
                            Button(action: { showingTestAccounts = true }) {
                                HStack {
                                    Image(systemName: "person.3.fill")
                                    Text("View All Test Accounts")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Text("Password: accountName + 'p'")
                                .font(.caption2)
                                .foregroundColor(.blue.opacity(0.8))
                                .italic()
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .alert("login.failed".localized(), isPresented: $showingError) {
                Button("common.ok".localized(), role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingFaceLogin) {
                FaceLoginView { success in
                    if success {
                        showingMainApp = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showingMainApp) {
                MainTabView()
                    .environmentObject(userService)
                    .overlay(alignment: .topTrailing) {
                        FloatingUserSwitcher(userService: userService)
                    }
            }
            .sheet(isPresented: $showingTestAccounts) {
                TestAccountsListView()
            }
        }
    }
    
    private func performLogin() {
        isLoggingIn = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoggingIn = false
            
            // Use TestData to validate login
            if let account = TestData.validateLogin(id: employeeId, password: password) {
                userService.currentUser = User(
                    id: account.id,
                    name: account.name,
                    isAdmin: account.isAdmin
                )
                showingMainApp = true
            } else {
                errorMessage = "login.errorMessage".localized()
                showingError = true
            }
        }
    }
}

struct FaceLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isScanning = false
    let onComplete: (Bool) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("attendance.faceToCamera".localized())
                    .font(.title2)
                    .fontWeight(.medium)
                
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 250, height: 250)
                    
                    if isScanning {
                        Circle()
                            .stroke(Color.blue, lineWidth: 3)
                            .frame(width: 250, height: 250)
                            .scaleEffect(1.2)
                            .opacity(0)
                            .animation(
                                Animation.easeOut(duration: 1.5)
                                    .repeatForever(autoreverses: false),
                                value: isScanning
                            )
                    }
                    
                    Image(systemName: "face.smiling")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                }
                
                Text(isScanning ? "Recognizing..." : "Click to start recognition")
                    .foregroundColor(.secondary)
                
                Button(action: startFaceRecognition) {
                    Text(isScanning ? "Recognizing" : "Start Recognition")
                        .frame(width: 200, height: 50)
                        .background(isScanning ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .disabled(isScanning)
            }
            .navigationTitle("login.faceLogin".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startFaceRecognition() {
        isScanning = true
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isScanning = false
            onComplete(true)
            dismiss()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserService())
}