import SwiftUI
import PDFKit

struct StudyView: View {
    @ObservedObject var aiService: AIService
    @Binding var showFilePicker: Bool
    @Binding var selectedPDF: PDFDocument?
    @Binding var questions: [TriviaQuestion]
    @Binding var pdfText: String
    @Binding var isLoading: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        ZStack {
            // Background gradient
            Theme.gradient2
                .opacity(0.1)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Welcome Card
                    Theme.card {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(Theme.accent2)
                                    .font(.title2)
                                Text("Welcome to Sikum")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            Text("Transform your study materials into interactive learning experiences")
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    // Upload Section
                    Theme.card {
                        VStack(spacing: 20) {
                            if selectedPDF == nil {
                                uploadPrompt
                            } else {
                                pdfPreview
                            }
                        }
                    }
                    
                    // Generate Questions Button
                    if selectedPDF != nil && !isLoading {
                        generateButton
                    }
                    
                    // Loading State
                    if isLoading {
                        loadingView
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker(types: [.pdf]) { result in
                handlePDFSelection(result)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handlePDFSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            if let pdf = PDFDocument(url: url) {
                selectedPDF = pdf
                // Extract text from PDF
                if let text = pdf.string {
                    self.pdfText = text
                } else {
                    errorMessage = "Could not extract text from PDF"
                    showError = true
                }
            } else {
                errorMessage = "Could not load PDF"
                showError = true
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private var uploadPrompt: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Theme.accent2.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "arrow.up.doc.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Theme.accent2)
            }
            
            Text("Upload PDF")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            Text("Select your study material to get started")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                showFilePicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Choose PDF")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.gradient1)
                .cornerRadius(15)
            }
        }
        .padding()
    }
    
    private var pdfPreview: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundColor(Theme.accent1)
                Text("Selected Document")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Divider()
            
            if let pdf = selectedPDF {
                PDFKitView(pdf: pdf)
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            
            Button {
                selectedPDF = nil
                pdfText = ""
            } label: {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Remove PDF")
                }
                .foregroundColor(Theme.error)
            }
        }
    }
    
    private var generateButton: some View {
        Button {
            Task {
                isLoading = true
                do {
                    questions = try await aiService.generateTrivia(from: pdfText)
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
                isLoading = false
            }
        } label: {
            HStack {
                Image(systemName: "wand.and.stars")
                Text("Generate Questions")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.gradient1)
            .cornerRadius(15)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Theme.accent2)
            
            Text("Generating questions...")
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(15)
    }
}

struct PDFKitView: UIViewRepresentable {
    let pdf: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdf
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdf
    }
}
