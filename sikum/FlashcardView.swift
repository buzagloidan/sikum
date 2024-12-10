import SwiftUI

struct FlashcardView: View {
    let questions: [TriviaQuestion]
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var offset = CGSize.zero
    @State private var degrees = 0.0
    
    var body: some View {
        ZStack {
            // Background gradient
            Theme.gradient2
                .opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Progress bar and counter
                VStack(spacing: 8) {
                    ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                        .tint(Theme.accent2)
                        .padding(.horizontal)
                    
                    Text("\(currentIndex + 1) of \(questions.count)")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.top)
                
                // Flashcard
                ZStack {
                    // Question side
                    Group {
                        CardContent(
                            title: "Question",
                            content: questions[currentIndex].question,
                            showHint: true,
                            icon: "questionmark.circle.fill"
                        )
                        .opacity(showAnswer ? 0 : 1)
                    }
                    .rotation3DEffect(.degrees(showAnswer ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                    
                    // Answer side
                    Group {
                        CardContent(
                            title: "Answer",
                            content: questions[currentIndex].correctAnswer,
                            showHint: false,
                            icon: "checkmark.circle.fill"
                        )
                        .opacity(showAnswer ? 1 : 0)
                    }
                    .rotation3DEffect(.degrees(showAnswer ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                }
                .frame(height: 400)
                .padding(.horizontal)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showAnswer.toggle()
                    }
                }
                
                // Navigation buttons
                HStack(spacing: 30) {
                    // Previous button
                    NavigationButton(
                        icon: "arrow.left.circle.fill",
                        isEnabled: currentIndex > 0,
                        action: previousCard
                    )
                    
                    // Flip button
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showAnswer.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: showAnswer ? "eye.slash.fill" : "eye.fill")
                            Text(showAnswer ? "Hide Answer" : "Show Answer")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Theme.gradient1)
                        .cornerRadius(15)
                        .shadow(color: Theme.cardShadow, radius: 5)
                    }
                    
                    // Next button
                    NavigationButton(
                        icon: "arrow.right.circle.fill",
                        isEnabled: currentIndex < questions.count - 1,
                        action: nextCard
                    )
                }
                .padding(.bottom)
            }
            .padding()
        }
        .navigationTitle("Flashcards")
    }
    
    private func nextCard() {
        if currentIndex < questions.count - 1 {
            withAnimation {
                showAnswer = false
                currentIndex += 1
            }
        }
    }
    
    private func previousCard() {
        if currentIndex > 0 {
            withAnimation {
                showAnswer = false
                currentIndex -= 1
            }
        }
    }
}

struct CardContent: View {
    let title: String
    let content: String
    let showHint: Bool
    let icon: String
    
    var body: some View {
        Theme.card {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(Theme.accent2)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Content
                Text(content)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textPrimary)
                    .padding(.horizontal)
                
                Spacer()
                
                // Hint
                if showHint {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                        Text("Tap to flip")
                            .font(.caption)
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
            .padding()
        }
    }
}

struct NavigationButton: View {
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(isEnabled ? Theme.accent2 : Theme.textSecondary.opacity(0.3))
        }
        .disabled(!isEnabled)
    }
}
