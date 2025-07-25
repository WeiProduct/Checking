import Foundation

// OpenAI API Request Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let max_tokens: Int
    
    init(model: String = APIConfiguration.defaultModel, messages: [OpenAIMessage], temperature: Double = APIConfiguration.temperature, maxTokens: Int = APIConfiguration.maxTokens) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.max_tokens = maxTokens
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

// OpenAI API Response Models
struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?
}

struct Choice: Codable {
    let index: Int
    let message: OpenAIMessage
    let finish_reason: String?
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}