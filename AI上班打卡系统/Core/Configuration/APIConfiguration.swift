import Foundation

struct APIConfiguration {
    // IMPORTANT: Never hardcode API keys in production code
    // For development only - in production, use environment variables or secure storage
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY_HERE" // Replace with actual key from secure storage
    
    static let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    static let defaultModel = "gpt-3.5-turbo"
    static let maxTokens = 1000
    static let temperature = 0.7
}