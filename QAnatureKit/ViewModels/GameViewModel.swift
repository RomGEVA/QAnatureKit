import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var player: Player
    @Published var currentQuestions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var isQuizCompleted: Bool = false
    @Published var showHint: Bool = false
    @Published var remainingTime: Int = 35 // 35 секунд на весь квиз
    @Published var mistakesCount: Int = 0 // Счетчик ошибок
    @Published var maxMistakes: Int = 3 // Максимальное количество ошибок
    @Published var disabledOptions: Set<Int> = [] // Для подсказки 50/50
    @Published var currentCategory: QuestionCategory = .animals
    @Published var categoryQuizCounts: [QuestionCategory: Int] = [:]
    
    private var timer: Timer?
    private let questionsPerQuiz = 10
    private let quizBonus = 50
    private let totalQuizTime = 35 // 35 секунд на весь квиз
    
    init() {
        // Загрузка данных игрока из UserDefaults
        if let data = UserDefaults.standard.data(forKey: "player"),
           let savedPlayer = try? JSONDecoder().decode(Player.self, from: data) {
            self.player = savedPlayer
        } else {
            self.player = Player.default
        }
        
        // Инициализация счетчиков категорий
        for category in QuestionCategory.allCases {
            categoryQuizCounts[category] = 0
        }
        
        loadQuestions()
    }
    
    private func loadQuestions() {
        print("Начинаем загрузку вопросов...")
        
        // Получаем путь к файлу
        guard let path = Bundle.main.path(forResource: "questions", ofType: "json") else {
            print("❌ Не удалось найти путь к файлу questions.json")
            return
        }
        print("✅ Путь к файлу найден: \(path)")
        
        do {
            // Читаем содержимое файла
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            print("✅ Файл успешно прочитан, размер: \(data.count) байт")
            
            // Декодируем JSON
            let decoder = JSONDecoder()
            let questionsContainer = try decoder.decode(QuestionsContainer.self, from: data)
            print("✅ JSON успешно декодирован")
            print("📚 Количество вопросов в файле: \(questionsContainer.questions.count)")
            
            // Выбираем случайные вопросы
            currentQuestions = Array(questionsContainer.questions.shuffled().prefix(questionsPerQuiz))
            print("🎲 Выбрано случайных вопросов: \(currentQuestions.count)")
            
        } catch {
            print("❌ Ошибка при загрузке вопросов: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Данные повреждены: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Ключ не найден: \(key.stringValue), \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Несоответствие типа: \(type), \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Значение не найдено: \(type), \(context.debugDescription)")
                @unknown default:
                    print("Неизвестная ошибка декодирования")
                }
            }
        }
    }
    
    func startNewQuiz() {
        print("🔄 Начинаем новый квиз")
        resetQuizState()
        loadQuestions()
        startTimer()
        print("⏱️ Таймер запущен, оставшееся время: \(remainingTime) секунд")
    }
    
    func resetQuizState() {
        stopTimer() // Останавливаем таймер перед сбросом состояния
        currentQuestionIndex = 0
        score = 0
        isQuizCompleted = false
        showHint = false
        remainingTime = totalQuizTime
        mistakesCount = 0 // Сбрасываем счетчик ошибок
        disabledOptions.removeAll()
        currentQuestions = []
    }
    
    func useHint(_ hintType: HintType) {
        guard player.coins >= hintType.cost else { return }
        
        player.coins -= hintType.cost
        savePlayerData()
        
        switch hintType {
        case .skip:
            moveToNextQuestion()
        case .fiftyFifty:
            useFiftyFiftyHint()
        case .highlight:
            showHint = true
        }
    }
    
    private func useFiftyFiftyHint() {
        guard currentQuestionIndex < currentQuestions.count else { return }
        
        let question = currentQuestions[currentQuestionIndex]
        var wrongOptions = Set(0..<question.options.count)
        wrongOptions.remove(question.correctAnswerIndex)
        
        // Выбираем два случайных неправильных ответа
        let optionsToDisable = Array(wrongOptions).shuffled().prefix(2)
        disabledOptions = Set(optionsToDisable)
    }
    
    func answerQuestion(_ answerIndex: Int) {
        guard currentQuestionIndex < currentQuestions.count else { return }
        
        // Проверяем, не отключен ли этот вариант ответа подсказкой 50/50
        if disabledOptions.contains(answerIndex) {
            return
        }
        
        let question = currentQuestions[currentQuestionIndex]
        if answerIndex == question.correctAnswerIndex {
            score += question.difficulty.reward
        } else {
            mistakesCount += 1
            if mistakesCount >= maxMistakes {
                completeQuiz()
                return
            }
        }
        
        moveToNextQuestion()
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < currentQuestions.count - 1 {
            currentQuestionIndex += 1
            showHint = false
            disabledOptions.removeAll() // Сбрасываем отключенные варианты
        } else {
            completeQuiz()
        }
    }
    
    private func completeQuiz() {
        stopTimer() // Останавливаем таймер при завершении квиза
        isQuizCompleted = true
        player.coins += score + quizBonus
        player.completedQuizzes += 1
        savePlayerData()
        
        checkAchievements()
    }
    
    private func checkAchievements() {
        var achievementsUnlocked = false
        
        // Общие достижения
        if player.completedQuizzes == 1 {
            if let index = player.achievements.firstIndex(where: { $0.id == "first_quiz" }) {
                if !player.achievements[index].isUnlocked {
                    player.achievements[index].unlock()
                    player.coins += Achievement.firstQuiz.reward
                    achievementsUnlocked = true
                }
            } else {
                var achievement = Achievement.firstQuiz
                achievement.unlock()
                player.achievements.append(achievement)
                player.coins += achievement.reward
                achievementsUnlocked = true
            }
        }
        
        if player.completedQuizzes == 5 {
            if let index = player.achievements.firstIndex(where: { $0.id == "nature_expert" }) {
                if !player.achievements[index].isUnlocked {
                    player.achievements[index].unlock()
                    player.coins += Achievement.natureExpert.reward
                    achievementsUnlocked = true
                }
            } else {
                var achievement = Achievement.natureExpert
                achievement.unlock()
                player.achievements.append(achievement)
                player.coins += achievement.reward
                achievementsUnlocked = true
            }
        }
        
        // Достижения за категории
        let categoryCount = player.getCategoryCount(currentCategory)
        
        // Достижения "Любитель"
        let loverAchievement: Achievement
        let masterAchievement: Achievement
        switch currentCategory {
        case .animals:
            loverAchievement = Achievement.animalLover
            masterAchievement = Achievement.animalMaster
        case .plants:
            loverAchievement = Achievement.plantLover
            masterAchievement = Achievement.plantMaster
        case .ecology:
            loverAchievement = Achievement.ecoLover
            masterAchievement = Achievement.ecoMaster
        case .water:
            loverAchievement = Achievement.waterLover
            masterAchievement = Achievement.waterMaster
        case .fungi:
            loverAchievement = Achievement.fungiLover
            masterAchievement = Achievement.fungiMaster
        case .birds:
            loverAchievement = Achievement.birdsLover
            masterAchievement = Achievement.birdsMaster
        }
        
        if categoryCount == 1 {
            if let index = player.achievements.firstIndex(where: { $0.id == loverAchievement.id }) {
                if !player.achievements[index].isUnlocked {
                    player.achievements[index].unlock()
                    player.coins += loverAchievement.reward
                    achievementsUnlocked = true
                }
            } else {
                var achievement = loverAchievement
                achievement.unlock()
                player.achievements.append(achievement)
                player.coins += achievement.reward
                achievementsUnlocked = true
            }
        }
        
        // Достижения "Мастер"
        if categoryCount == 3 {
            if let index = player.achievements.firstIndex(where: { $0.id == masterAchievement.id }) {
                if !player.achievements[index].isUnlocked {
                    player.achievements[index].unlock()
                    player.coins += masterAchievement.reward
                    achievementsUnlocked = true
                }
            } else {
                var achievement = masterAchievement
                achievement.unlock()
                player.achievements.append(achievement)
                player.coins += achievement.reward
                achievementsUnlocked = true
            }
        }
        
        // Достижение за скорость
        if remainingTime >= 15 { // Если прошло менее 20 секунд
            if let index = player.achievements.firstIndex(where: { $0.id == "speedster" }) {
                if !player.achievements[index].isUnlocked {
                    player.achievements[index].unlock()
                    player.coins += Achievement.speedster.reward
                    achievementsUnlocked = true
                }
            } else {
                var achievement = Achievement.speedster
                achievement.unlock()
                player.achievements.append(achievement)
                player.coins += achievement.reward
                achievementsUnlocked = true
            }
        }
        
        // Достижение за точность
        if mistakesCount == 0 {
            if let index = player.achievements.firstIndex(where: { $0.id == "perfect_score" }) {
                if !player.achievements[index].isUnlocked {
                    player.achievements[index].unlock()
                    player.coins += Achievement.perfectScore.reward
                    achievementsUnlocked = true
                }
            } else {
                var achievement = Achievement.perfectScore
                achievement.unlock()
                player.achievements.append(achievement)
                player.coins += achievement.reward
                achievementsUnlocked = true
            }
        }
        
        if achievementsUnlocked {
            savePlayerData()
            objectWillChange.send()
        }
    }
    
    func startNewQuiz(for category: QuestionCategory) {
        currentCategory = category
        player.incrementCategoryCount(category)
        startNewQuiz()
    }
    
    private func startTimer() {
        stopTimer() // Останавливаем предыдущий таймер перед запуском нового
        print("⏱️ Запуск таймера")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                print("⏱️ Оставшееся время: \(self.remainingTime) секунд")
            } else {
                print("⏱️ Время истекло")
                self.completeQuiz() // Завершаем квиз, если время истекло
            }
        }
        // Добавляем таймер в RunLoop для работы в фоновом режиме
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        print("⏱️ Остановка таймера")
        timer?.invalidate()
        timer = nil
    }
    
    private func savePlayerData() {
        if let encoded = try? JSONEncoder().encode(player) {
            UserDefaults.standard.set(encoded, forKey: "player")
        }
    }
    
    func resetProgress() {
        player = Player.default
        savePlayerData()
    }
    
    deinit {
        stopTimer() // Останавливаем таймер при уничтожении ViewModel
    }
}

// Структура для декодирования JSON
struct QuestionsContainer: Codable {
    let questions: [Question]
}

enum HintType {
    case skip
    case fiftyFifty
    case highlight
    
    var cost: Int {
        switch self {
        case .skip: return 30
        case .fiftyFifty: return 20
        case .highlight: return 40
        }
    }
} 
