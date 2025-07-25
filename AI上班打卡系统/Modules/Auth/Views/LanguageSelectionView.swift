import SwiftUI

struct LanguageSelectionView: View {
    @StateObject private var languageService = LanguageService.shared
    @State private var selectedLanguage: Language?
    @State private var showNextScreen = false
    @State private var animateLanguages = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Logo和标题
                VStack(spacing: 20) {
                    Image(systemName: "faceid")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .scaleEffect(animateLanguages ? 1.0 : 0.8)
                        .opacity(animateLanguages ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6), value: animateLanguages)
                    
                    Text("language.select")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(animateLanguages ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateLanguages)
                }
                .padding(.top, 60)
                
                // 语言选择按钮
                HStack(spacing: 30) {
                    // 中文按钮
                    LanguageButton(
                        language: .chinese,
                        isSelected: selectedLanguage == .chinese,
                        action: {
                            withAnimation(.spring()) {
                                selectedLanguage = .chinese
                            }
                        }
                    )
                    .scaleEffect(animateLanguages ? 1.0 : 0.8)
                    .opacity(animateLanguages ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateLanguages)
                    
                    // 英文按钮
                    LanguageButton(
                        language: .english,
                        isSelected: selectedLanguage == .english,
                        action: {
                            withAnimation(.spring()) {
                                selectedLanguage = .english
                            }
                        }
                    )
                    .scaleEffect(animateLanguages ? 1.0 : 0.8)
                    .opacity(animateLanguages ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: animateLanguages)
                }
                
                Spacer()
                
                // 继续按钮
                if selectedLanguage != nil {
                    Button(action: continueToApp) {
                        Text(selectedLanguage == .chinese ? "继续" : "Continue")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            withAnimation {
                animateLanguages = true
            }
        }
        .fullScreenCover(isPresented: $showNextScreen) {
            SplashView()
                .environmentObject(languageService)
        }
    }
    
    private func continueToApp() {
        guard let language = selectedLanguage else { return }
        languageService.setLanguage(language)
        showNextScreen = true
    }
}

struct LanguageButton: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                // 语言图标
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Text(language == .chinese ? "中" : "EN")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(isSelected ? .blue : .white)
                }
                
                // 语言名称
                Text(language.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // 选中指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LanguageSelectionView()
}