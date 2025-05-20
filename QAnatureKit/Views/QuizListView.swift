import SwiftUI

struct QuizListView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var selectedCategory: QuestionCategory?
    @State private var isShowingQuiz = false
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("BrightPink"), Color("BrightOrange")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    Section(header: Text("Available Quizzes").foregroundColor(.black)) {
                        ForEach(QuestionCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                viewModel.startNewQuiz(for: category)
                                isShowingQuiz = true
                            }) {
                                QuizRow(category: category)
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.clear)
                .navigationTitle("Quizzes")
                .fullScreenCover(isPresented: $isShowingQuiz) {
                    QuizView(viewModel: viewModel, isShowingQuiz: $isShowingQuiz)
                }
            }.padding()
            }
        }
    }
}

struct QuizRow: View {
    let category: QuestionCategory
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(Color("BrightYellow"))
                .frame(width: 40)
           
                Text(category.displayName)
                    .font(.headline)
                    .foregroundColor(.black)
            Spacer()
                Text("10 questions")
                    .font(.subheadline)
                    .foregroundColor(Color("BrightPink"))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Color.white.opacity(0.95))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("BrightOrange"), lineWidth: 3)
        )
        .shadow(color: Color("BrightPink").opacity(0.10), radius: 4, x: 0, y: 2)
    }
    
    private var iconName: String {
        switch category {
        case .animals: return "hare.fill"
        case .plants: return "leaf.fill"
        case .ecology: return "globe.europe.africa.fill"
        case .water:
            return "water.waves"
        case .fungi:
            return "eraser.fill"
        case .birds:
            return "bird.fill"
        }
    }
}

extension QuestionCategory: CaseIterable {
    static var allCases: [QuestionCategory] = [.animals, .plants, .ecology, .water, .fungi, .birds]
}

extension QuestionCategory: Identifiable {
    var id: String { self.rawValue }
}

struct QuizListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizListView(viewModel: GameViewModel())
    }
} 
