import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingCompleted: Bool?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("BrightPink"), Color("BrightOrange")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        imageName: "onboarding1",
                        title: "Welcome to QAnature!",
                        description: "Test your knowledge about nature and learn interesting facts about animals, plants, and ecology."
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        imageName: "onboarding2",
                        title: "Earn Achievements",
                        description: "Complete quizzes, earn coins, and unlock achievements as you explore the fascinating world of nature."
                    )
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                Button(action: {
                    if currentPage < 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isOnboardingCompleted = true
                    }
                }) {
                    Text(currentPage < 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.brightPink)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(.top, 50)
                .cornerRadius(10)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isOnboardingCompleted: .constant(false))
} 
