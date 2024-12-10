import SwiftUI
import PDFKit

struct MainTabView: View {
    @StateObject private var aiService = AIService()
    @State private var selectedTab = 0
    @State private var showFilePicker = false
    @State private var selectedPDF: PDFDocument?
    @State private var questions = [TriviaQuestion]()
    @State private var pdfText: String = ""
    @State private var isLoading: Bool = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StudyView(
                aiService: aiService,
                showFilePicker: $showFilePicker,
                selectedPDF: $selectedPDF,
                questions: $questions,
                pdfText: $pdfText,
                isLoading: $isLoading,
                showError: $showError,
                errorMessage: $errorMessage
            )
            .tabItem {
                Label("Study", systemImage: "book.fill")
            }
            .tag(0)
            
            if !questions.isEmpty {
                FlashcardView(questions: questions)
                    .tabItem {
                        Label("Cards", systemImage: "square.stack.fill")
                    }
                    .tag(1)
                
                QuizView(questions: questions)
                    .tabItem {
                        Label("Quiz", systemImage: "checkmark.circle.fill")
                    }
                    .tag(2)
            }
        }
        .tint(Theme.primary)
        .background(Theme.background)
    }
}
