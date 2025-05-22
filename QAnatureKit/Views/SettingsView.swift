import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("BrightPink"), Color("BrightOrange")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Button(action: {
                        SKStoreReviewController.requestReview()
                    }) {
                        SettingsButtonRow(icon: "star.fill", title: "Rate App", color: Color("BrightYellow"))
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://www.termsfeed.com/live/26b5b286-7210-4cca-89f5-cd4a79706b66") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        SettingsButtonRow(icon: "lock.shield.fill", title: "Privacy Policy", color: Color("BrightOrange"))
                    }
                    
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        SettingsButtonRow(icon: "arrow.counterclockwise", title: "Reset Progress", color: Color("BrightRed"))
                    }
                }
                .padding()
                .navigationTitle("Settings")
            }
        }
        .alert("Reset Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetProgress()
            }
        } message: {
            Text("This action cannot be undone. All progress, coins, and achievements will be reset.")
        }
    }
}

struct SettingsButtonRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.95))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color, lineWidth: 3)
        )
        .shadow(color: color.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: GameViewModel())
    }
} 
