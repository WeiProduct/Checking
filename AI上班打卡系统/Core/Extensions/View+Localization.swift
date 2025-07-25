import SwiftUI

// 创建一个环境值来访问语言服务
private struct LanguageServiceKey: EnvironmentKey {
    @MainActor
    static var defaultValue: LanguageService {
        LanguageService.shared
    }
}

extension EnvironmentValues {
    var languageService: LanguageService {
        get { self[LanguageServiceKey.self] }
        set { self[LanguageServiceKey.self] = newValue }
    }
}

// 本地化文本视图
struct LocalizedTextView: View {
    let key: String
    @ObservedObject private var languageService = LanguageService.shared
    
    var body: some View {
        Text(key.localized())
    }
}

// View扩展方法
extension View {
    func onLanguageChange(perform action: @escaping (Language) -> Void) -> some View {
        self.onReceive(LanguageService.shared.$currentLanguage) { language in
            action(language)
        }
    }
}

// 便捷的本地化组件
struct LText: View {
    let key: String
    @ObservedObject private var languageService = LanguageService.shared
    
    init(_ key: String) {
        self.key = key
    }
    
    var body: some View {
        Text(key.localized())
    }
}