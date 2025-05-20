import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("BrightPink"), Color("BrightOrange")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        ForEach(getAllAchievements()) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                    .navigationTitle("Achievements")
                }.padding()
            }
        }
    }
    
    private func getAllAchievements() -> [Achievement] {
        var allAchievements: [Achievement] = [
            .firstQuiz, .natureExpert,
            .animalLover, .animalMaster,
            .plantLover, .plantMaster,
            .ecoLover, .ecoMaster,
            .waterLover, .waterMaster,
            .fungiLover, .fungiMaster,
            .birdsLover, .birdsMaster,
            .speedster, .perfectScore
        ]
        // Обновляем статус достижений из сохранённых данных игрока
        for (index, achievement) in allAchievements.enumerated() {
            if let saved = viewModel.player.achievements.first(where: { $0.id == achievement.id }) {
                allAchievements[index].isUnlocked = saved.isUnlocked
            }
        }
        return allAchievements
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.isUnlocked ? "star.fill" : "star")
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            
            VStack(alignment: .leading) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Text("+\(achievement.reward) 🪙")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView(viewModel: GameViewModel())
    }
} 
