enum Config {
    static let geminiApiKey: String = {
        #if DEBUG
        return ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
        #else
        return "PRODUCTION_KEY" // Replace in production
        #endif
    }()
} 