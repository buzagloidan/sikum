import Foundation

class AIService: ObservableObject {
    private let apiKey: String
    
    init(apiKey: String? = nil) {
        self.apiKey = apiKey ?? Config.geminiApiKey
        
        if self.apiKey.isEmpty {
            print("Warning: No API key provided. The service will not work without a valid API key.")
        }
    }
    
    func generateTrivia(from text: String) async throws -> [TriviaQuestion] {
        guard !apiKey.isEmpty else {
            throw AIError.apiError("Missing API key")
        }
        
        let cleanedText = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(6000)
        
        let prompt = """
        You are a JSON generator. Generate 20 multiple choice questions based on this text.
        Return ONLY a valid JSON array with no additional text, comments, or formatting.
        Each object in the array must have exactly these fields:
        - "question": the question text
        - "correctAnswer": the correct answer
        - "incorrectAnswers": array of exactly 3 wrong answers
        
        Text to analyze:
        \(cleanedText)
        """
        
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 2048
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Print raw response for debugging
            print("Raw API Response:")
            print(String(data: data, encoding: .utf8) ?? "Could not decode response")
            
            // Decode the Google AI response
            let aiResponse = try JSONDecoder().decode(GoogleAIResponse.self, from: data)
            guard let content = aiResponse.candidates.first?.content.parts.first?.text else {
                throw AIError.invalidResponse
            }
            
            // Print AI response content for debugging
            print("\nAI Response Content:")
            print(content)
            
            // Clean up the response content
            var cleanedContent = content
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Remove any markdown or code block indicators
            let markdownPatterns = ["```json", "```javascript", "```", "`"]
            for pattern in markdownPatterns {
                cleanedContent = cleanedContent.replacingOccurrences(of: pattern, with: "")
            }
            
            cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Print cleaned content for debugging
            print("\nCleaned Content:")
            print(cleanedContent)
            
            // Verify we have a JSON array
            guard cleanedContent.hasPrefix("[") && cleanedContent.hasSuffix("]") else {
                throw AIError.processingError("Response is not a JSON array")
            }
            
            guard let jsonData = cleanedContent.data(using: .utf8) else {
                throw AIError.invalidData
            }
            
            // Try to parse as JSON first to validate
            guard let _ = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
                throw AIError.processingError("Invalid JSON array structure")
            }
            
            // Now try to decode into our model
            let questions = try JSONDecoder().decode([TriviaQuestion].self, from: jsonData)
            
            // Validate questions
            guard !questions.isEmpty else {
                throw AIError.processingError("No questions were generated")
            }
            
            return questions
            
        } catch {
            print("\nError details:")
            print(error)
            throw AIError.processingError(error.localizedDescription)
        }
    }
}

// Response models
struct GoogleAIResponse: Codable {
    let candidates: [Candidate]
    
    struct Candidate: Codable {
        let content: Content
    }
    
    struct Content: Codable {
        let parts: [Part]
    }
    
    struct Part: Codable {
        let text: String
    }
}

// Wrapper for the questions array
struct QuestionsWrapper: Codable {
    let questions: [TriviaQuestion]
}

enum AIError: Error, LocalizedError {
    case invalidResponse
    case invalidData
    case apiError(String)
    case processingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Could not process the response data"
        case .apiError(let message):
            return "API Error: \(message)"
        case .processingError(let message):
            return "Processing Error: \(message)"
        }
    }
}
