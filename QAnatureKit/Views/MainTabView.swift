import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var selectedTab = 0
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(named: "BrightPink")
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.7)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("BrightPink"), Color("BrightOrange")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            TabView(selection: $selectedTab) {
                ProfileView(viewModel: viewModel)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                            .foregroundColor(Color("BrightYellow"))
                    }
                    .tag(0)
                QuizListView(viewModel: viewModel)
                    .tabItem {
                        Label("Quizzes", systemImage: "list.bullet")
                            .foregroundColor(Color("BrightYellow"))
                    }
                    .tag(1)
                AchievementsView(viewModel: viewModel)
                    .tabItem {
                        Label("Achievements", systemImage: "star.fill")
                            .foregroundColor(Color("BrightYellow"))
                    }
                    .tag(2)
                SettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                            .foregroundColor(Color("BrightYellow"))
                    }
                    .tag(3)
            }
            .accentColor(.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 
