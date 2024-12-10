//
//  Models.swift
//  sikum
//
//  Created by Idan Buzaglo on 11/11/2024.
//

import Foundation

struct TriviaQuestion: Identifiable, Hashable, Codable {
    let id: UUID
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
    
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer
        case incorrectAnswers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.question = try container.decode(String.self, forKey: .question)
        self.correctAnswer = try container.decode(String.self, forKey: .correctAnswer)
        self.incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers)
    }
    
    init(question: String, correctAnswer: String, incorrectAnswers: [String]) {
        self.id = UUID()
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
    }
}
