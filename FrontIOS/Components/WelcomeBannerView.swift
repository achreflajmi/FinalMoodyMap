import SwiftUI

struct WelcomeBannerView: View {
    let userName: String
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(getGreeting())
                .font(.title2)
                .foregroundColor(themeManager.currentTheme == .dark ? .white : .gray)
            
            Text("Hello, \(userName)!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: themeManager.currentTheme == .dark ? "#000000" : "#fef2e4")) // Light mode background color
                .shadow(radius: 5)
        )
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}
