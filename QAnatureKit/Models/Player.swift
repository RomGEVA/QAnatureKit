import Foundation

struct Player: Codable {
    var nickname: String
    var coins: Int
    var completedQuizzes: Int
    var achievements: [Achievement]
    var categoryQuizCounts: [String: Int] // Сохраняем как [String: Int] для Codable
    
    static var `default`: Player {
        var counts: [String: Int] = [:]
        for category in QuestionCategory.allCases {
            counts[category.rawValue] = 0
        }
        return Player(nickname: "Player", coins: 0, completedQuizzes: 0, achievements: [], categoryQuizCounts: counts)
    }
    
    // Вспомогательные методы для работы с категориями
    mutating func incrementCategoryCount(_ category: QuestionCategory) {
        categoryQuizCounts[category.rawValue, default: 0] += 1
    }
    
    func getCategoryCount(_ category: QuestionCategory) -> Int {
        return categoryQuizCounts[category.rawValue, default: 0]
    }
}

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    var isUnlocked: Bool
    let reward: Int
    
    mutating func unlock() {
        isUnlocked = true
    }
    
    // General achievements
    static let firstQuiz = Achievement(
        id: "first_quiz",
        title: "First Step",
        description: "Complete your first quiz",
        isUnlocked: false,
        reward: 100
    )
    
    static let natureExpert = Achievement(
        id: "nature_expert",
        title: "Nature Expert",
        description: "Complete 5 quizzes",
        isUnlocked: false,
        reward: 500
    )
    
    // Achievements for "Animals" category
    static let animalLover = Achievement(
        id: "animal_lover",
        title: "Animal Lover",
        description: "Complete an animal quiz",
        isUnlocked: false,
        reward: 200
    )
    
    static let animalMaster = Achievement(
        id: "animal_master",
        title: "Animal Master",
        description: "Complete 3 animal quizzes",
        isUnlocked: false,
        reward: 400
    )
    
    // Achievements for "Plants" category
    static let plantLover = Achievement(
        id: "plant_lover",
        title: "Plant Lover",
        description: "Complete a plant quiz",
        isUnlocked: false,
        reward: 200
    )
    
    static let plantMaster = Achievement(
        id: "plant_master",
        title: "Plant Master",
        description: "Complete 3 plant quizzes",
        isUnlocked: false,
        reward: 400
    )
    
    // Achievements for "Ecology" category
    static let ecoLover = Achievement(
        id: "eco_lover",
        title: "Nature Defender",
        description: "Complete an ecology quiz",
        isUnlocked: false,
        reward: 200
    )
    
    static let ecoMaster = Achievement(
        id: "eco_master",
        title: "Ecology Master",
        description: "Complete 3 ecology quizzes",
        isUnlocked: false,
        reward: 400
    )
    
    // Speed achievements
    static let speedster = Achievement(
        id: "speedster",
        title: "Speedster",
        description: "Complete a quiz in less than 20 seconds",
        isUnlocked: false,
        reward: 300
    )
    
    // Accuracy achievements
    static let perfectScore = Achievement(
        id: "perfect_score",
        title: "Perfect Score",
        description: "Complete a quiz without mistakes",
        isUnlocked: false,
        reward: 500
    )
    
    // Achievements for "Water" category
    static let waterLover = Achievement(
        id: "water_lover",
        title: "Water Lover",
        description: "Complete a water quiz",
        isUnlocked: false,
        reward: 200
    )
    
    static let waterMaster = Achievement(
        id: "water_master",
        title: "Water Master",
        description: "Complete 3 water quizzes",
        isUnlocked: false,
        reward: 400
    )
    
    // Achievements for "Fungi" category
    static let fungiLover = Achievement(
        id: "fungi_lover",
        title: "Fungi Lover",
        description: "Complete a fungi quiz",
        isUnlocked: false,
        reward: 200
    )
    
    static let fungiMaster = Achievement(
        id: "fungi_master",
        title: "Fungi Master",
        description: "Complete 3 fungi quizzes",
        isUnlocked: false,
        reward: 400
    )
    
    // Achievements for "Birds" category
    static let birdsLover = Achievement(
        id: "birds_lover",
        title: "Bird Lover",
        description: "Complete a bird quiz",
        isUnlocked: false,
        reward: 200
    )
    
    static let birdsMaster = Achievement(
        id: "birds_master",
        title: "Bird Master",
        description: "Complete 3 bird quizzes",
        isUnlocked: false,
        reward: 400
    )
} 