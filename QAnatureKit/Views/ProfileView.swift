import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var isEditingNickname = false
    @State private var newNickname = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("BrightPink"), Color("BrightOrange")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    // Аватар
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color("BrightYellow"))
                        .shadow(color: Color("BrightRed").opacity(0.2), radius: 8, x: 0, y: 4)
                    // Никнейм
                    if isEditingNickname {
                        TextField("Enter nickname", text: $newNickname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        Button("Save") {
                            viewModel.player.nickname = newNickname
                            isEditingNickname = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("BrightOrange"))
                    } else {
                        Text(viewModel.player.nickname)
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 2)
                            .onTapGesture {
                                newNickname = viewModel.player.nickname
                                isEditingNickname = true
                            }
                    }
                    // Статистика
                    VStack(spacing: 15) {
                        StatisticRow(title: "Coins", value: "\(viewModel.player.coins)")
                        StatisticRow(title: "Completed Quizzes", value: "\(viewModel.player.completedQuizzes)")
                    }
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color("BrightOrange"), lineWidth: 3)
                    )
                    .shadow(color: Color("BrightPink").opacity(0.15), radius: 6, x: 0, y: 2)
                    Spacer()
                }
                .padding()
                .navigationTitle("Profile")
                .foregroundColor(.black)
            }
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(Color("BrightPink"))
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(Color("BrightRed"))
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: GameViewModel())
    }
} 
