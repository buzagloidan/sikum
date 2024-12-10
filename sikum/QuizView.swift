import SwiftUI

struct QuizView: View {
    let questions: [TriviaQuestion]
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var showFeedback = false
    @State private var isComplete = false
    @State private var currentQuestionAnswers: [String] = []
    
    var body: some View {
        ZStack {
            // Background
            Theme.gradient2
                .opacity(0.1)
                .ignoresSafeArea()
            
            if !isComplete {
                VStack(spacing: 20) {
                    // Progress and Score
                    HStack {
                        // Progress bar
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Question \(currentIndex + 1) of \(questions.count)")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                            ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                                .tint(Theme.accent2)
                        }
                        
                        Spacer()
                        
                        // Score
                        Text("Score: \(score)")
                            .font(.headline)
                            .foregroundColor(Theme.accent2)
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(15)
                    .shadow(color: Theme.cardShadow, radius: 5)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Question
                            Theme.card {
                                Text(questions[currentIndex].question)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.textPrimary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            // Answers
                            VStack(spacing: 12) {
                                ForEach(currentQuestionAnswers, id: \.self) { answer in
                                    AnswerButton(
                                        answer: answer,
                                        isSelected: selectedAnswer == answer,
                                        isCorrect: showFeedback ? answer == questions[currentIndex].correctAnswer : nil,
                                        wasSelected: showFeedback ? selectedAnswer == answer : false
                                    ) {
                                        if !showFeedback {
                                            handleAnswer(answer)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .onAppear {
                    setupCurrentQuestion()
                }
            } else {
                QuizCompleteView(score: score, total: questions.count) {
                    resetQuiz()
                }
            }
        }
        .navigationTitle("Quiz")
    }
    
    private func setupCurrentQuestion() {
        let correct = questions[currentIndex].correctAnswer
        let incorrect = questions[currentIndex].incorrectAnswers
        currentQuestionAnswers = (incorrect + [correct]).shuffled()
    }
    
    private func handleAnswer(_ answer: String) {
        selectedAnswer = answer
        showFeedback = true
        
        if answer == questions[currentIndex].correctAnswer {
            score += 1
        }
        
        // Move to next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentIndex < questions.count - 1 {
                withAnimation {
                    currentIndex += 1
                    selectedAnswer = nil
                    showFeedback = false
                    setupCurrentQuestion()
                }
            } else {
                withAnimation {
                    isComplete = true
                }
            }
        }
    }
    
    private func resetQuiz() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        showFeedback = false
        isComplete = false
        setupCurrentQuestion()
    }
}

struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool?
    let wasSelected: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if let isCorrect = isCorrect {
            if isCorrect {
                return Theme.success.opacity(0.2)
            }
            return wasSelected ? Theme.error.opacity(0.2) : Theme.cardBackground
        }
        return isSelected ? Theme.accent2.opacity(0.1) : Theme.cardBackground
    }
    
    var borderColor: Color {
        if let isCorrect = isCorrect {
            if isCorrect {
                return Theme.success
            }
            return wasSelected ? Theme.error : Theme.cardShadow
        }
        return isSelected ? Theme.accent2 : Theme.cardShadow
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(answer)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                        .foregroundColor(isCorrect ? Theme.success : Theme.error)
                        .font(.title3)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(color: Theme.cardShadow, radius: isSelected ? 5 : 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCorrect != nil)
    }
}

struct QuizCompleteView: View {
    let score: Int
    let total: Int
    let restartAction: () -> Void
    
    var body: some View {
        Theme.card {
            VStack(spacing: 25) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(Theme.success.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.success)
                }
                
                Text("Quiz Complete!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Theme.textPrimary)
                
                VStack(spacing: 10) {
                    Text("Your Score")
                        .font(.headline)
                        .foregroundColor(Theme.textSecondary)
                    
                    Text("\(score) out of \(total)")
                        .font(.title)
                        .bold()
                        .foregroundColor(Theme.accent2)
                    
                    Text("(\(Int((Double(score) / Double(total)) * 100))%)")
                        .font(.headline)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Button(action: restartAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Theme.gradient1)
                    .cornerRadius(15)
                    .shadow(color: Theme.cardShadow, radius: 5)
                }
            }
            .padding()
        }
        .padding()
    }
}
