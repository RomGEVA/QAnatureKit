import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var isShowingQuiz: Bool
    @State private var showResults = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("BrightPink"), Color("BrightOrange")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        viewModel.resetQuizState()
                        isShowingQuiz = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(Color("BrightRed"))
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(Color("BrightYellow"))
                        Text("\(viewModel.player.coins)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.currentQuestions.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 2)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<viewModel.maxMistakes, id: \.self) { index in
                            Image(systemName: index < viewModel.mistakesCount ? "xmark.circle.fill" : "circle.fill")
                                .foregroundColor(index < viewModel.mistakesCount ? Color("BrightRed") : Color("BrightYellow"))
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 2)
                        }
                    }
                }
                .padding()
                
                Text(timeString(from: viewModel.remainingTime))
                    .font(.title)
                    .foregroundColor(viewModel.remainingTime <= 10 ? Color("BrightRed") : .white)
                    .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 2)
                    .padding()
                
                if viewModel.currentQuestionIndex < viewModel.currentQuestions.count {
                    let question = viewModel.currentQuestions[viewModel.currentQuestionIndex]
                    
                    Text(question.text)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                        .padding()
                    
                    VStack(spacing: 12) {
                        ForEach(question.options.indices, id: \.self) { index in
                            Button(action: {
                                viewModel.answerQuestion(index)
                            }) {
                                Text(question.options[index])
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(viewModel.disabledOptions.contains(index) ? 0.5 : 0.95))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                viewModel.showHint && index == question.correctAnswerIndex ? Color("BrightYellow") : Color("BrightOrange"),
                                                lineWidth: 3
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                            }
                            .disabled(viewModel.disabledOptions.contains(index))
                        }
                    }
                    .padding()
                    
                    HStack(spacing: 20) {
                        HintButtonStyled(icon: "forward.fill", text: "Skip", cost: 30, color: Color("BrightOrange"), enabled: viewModel.player.coins >= 30) {
                            viewModel.useHint(.skip)
                        }
                        HintButtonStyled(icon: "scissors", text: "50/50", cost: 20, color: Color("BrightOrange"), enabled: viewModel.player.coins >= 20) {
                            viewModel.useHint(.fiftyFifty)
                        }
                        HintButtonStyled(icon: "lightbulb.fill", text: "Hint", cost: 40, color: Color("BrightOrange"), enabled: viewModel.player.coins >= 40) {
                            viewModel.useHint(.highlight)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.isQuizCompleted) { completed in
            if completed {
                showResults = true
            }
        }
        .fullScreenCover(isPresented: $showResults) {
            QuizResultView(viewModel: viewModel, isShowingQuiz: $isShowingQuiz)
        }
        .onAppear {
            viewModel.startNewQuiz()
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct QuizContentView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Таймер
            TimerView(timeRemaining: viewModel.remainingTime)
            
            // Прогресс
            ProgressView(value: Double(viewModel.currentQuestionIndex + 1),
                        total: Double(viewModel.currentQuestions.count))
                .padding(.horizontal)
            
            if let currentQuestion = viewModel.currentQuestions[safe: viewModel.currentQuestionIndex] {
                // Вопрос
                Text(currentQuestion.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Варианты ответов
                ForEach(currentQuestion.options.indices, id: \.self) { index in
                    AnswerButton(
                        text: currentQuestion.options[index],
                        isCorrect: viewModel.showHint && index == currentQuestion.correctAnswerIndex
                    ) {
                        viewModel.answerQuestion(index)
                    }
                }
                
                // Подсказки
                HStack(spacing: 20) {
                    HintButton(type: .fiftyFifty, cost: 20) {
                        viewModel.useHint(.fiftyFifty)
                    }
                    
                    HintButton(type: .skip, cost: 30) {
                        viewModel.useHint(.skip)
                    }
                    
                    HintButton(type: .highlight, cost: 40) {
                        viewModel.useHint(.highlight)
                    }
                }
                .padding()
            } else {
                Text("Нет доступных вопросов")
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            print("QuizContentView appeared")
            viewModel.startNewQuiz()
        }
    }
}

struct TimerView: View {
    let timeRemaining: Int
    
    var body: some View {
        Text("\(timeRemaining)")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundColor(timeRemaining <= 10 ? .red : .primary)
    }
}

struct AnswerButton: View {
    let text: String
    let isCorrect: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isCorrect ? Color.green : Color.blue)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct HintButton: View {
    let type: HintType
    let cost: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName)
                    .font(.title2)
                Text("\(cost) 🪙")
                    .font(.caption)
            }
            .foregroundColor(.white)
            .frame(width: 80, height: 60)
            .background(Color.orange)
            .cornerRadius(10)
        }
    }
    
    private var iconName: String {
        switch type {
        case .fiftyFifty: return "scissors"
        case .skip: return "forward.fill"
        case .highlight: return "lightbulb.fill"
        }
    }
}

struct QuizResultView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var isShowingQuiz: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Quiz Completed!")
                .font(.title)
                .bold()
            
            Text("Coins earned: \(viewModel.score + 50)")
                .font(.title2)
            
            Button("Back to List") {
                viewModel.resetQuizState()
                isShowingQuiz = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(viewModel: GameViewModel(), isShowingQuiz: .constant(true))
    }
}

struct HintButtonStyled: View {
    let icon: String
    let text: String
    let cost: Int
    let color: Color
    let enabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.black)
                Text("\(cost) 🪙")
                    .font(.caption2)
                    .foregroundColor(.black)
            }
            .frame(width: 80, height: 60)
            .background(Color.white.opacity(enabled ? 0.95 : 0.5))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
        }
        .disabled(!enabled)
    }
} 
