import Foundation
import Combine

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Add welcome message
        messages.append(ChatMessage(
            content: "Hello! I'm your AI assistant. How can I help you today?",
            isUser: false
        ))
    }
    
    func sendMessage() {
        guard !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: currentMessage, isUser: true)
        messages.append(userMessage)
        
        // Store the message and clear input
        let messageToSend = currentMessage
        currentMessage = ""
        
        // Send to OpenAI
        Task {
            await sendToOpenAI(message: messageToSend)
        }
    }
    
    private func sendToOpenAI(message: String) async {
        isLoading = true
        errorMessage = nil
        
        // Prepare messages for API
        var apiMessages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: "You are a helpful AI assistant for an attendance management system. Provide clear and concise answers.")
        ]
        
        // Add conversation history (last 10 messages)
        for msg in messages.suffix(10) {
            apiMessages.append(OpenAIMessage(
                role: msg.isUser ? "user" : "assistant",
                content: msg.content
            ))
        }
        
        // Create request
        let request = OpenAIRequest(messages: apiMessages)
        
        do {
            let response = try await callOpenAIAPI(request: request)
            
            if let firstChoice = response.choices.first {
                let aiMessage = ChatMessage(
                    content: firstChoice.message.content,
                    isUser: false
                )
                messages.append(aiMessage)
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            let errorMsg = ChatMessage(
                content: "Sorry, I encountered an error. Please try again.",
                isUser: false
            )
            messages.append(errorMsg)
        }
        
        isLoading = false
    }
    
    private func callOpenAIAPI(request: OpenAIRequest) async throws -> OpenAIResponse {
        guard let url = URL(string: APIConfiguration.openAIEndpoint) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(APIConfiguration.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(OpenAIResponse.self, from: data)
    }
    
    func clearChat() {
        messages = [ChatMessage(
            content: "Hello! I'm your AI assistant. How can I help you today?",
            isUser: false
        )]
        errorMessage = nil
    }
}