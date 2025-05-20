import Foundation

struct Question: Codable, Identifiable {
    let id: Int
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
    let category: QuestionCategory
    let difficulty: QuestionDifficulty
    
    var correctAnswer: String {
        options[correctAnswerIndex]
    }
}

enum QuestionCategory: String, Codable {
    case animals = "animals"
    case plants = "plants"
    case ecology = "ecology"
    case water = "water"
    case fungi = "fungi"
    case birds = "birds"
    
    var displayName: String {
        switch self {
        case .animals: return "Animals"
        case .plants: return "Plants"
        case .ecology: return "Ecology"
        case .water: return "Water"
        case .fungi: return "Fungi"
        case .birds: return "Birds"
        }
    }
}

enum QuestionDifficulty: String, Codable {
    case easy
    case medium
    case hard
    
    var reward: Int {
        switch self {
        case .easy: return 10
        case .medium: return 15
        case .hard: return 20
        }
    }
} 