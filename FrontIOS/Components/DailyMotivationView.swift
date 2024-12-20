import SwiftUI

struct DailyMotivationView: View {
    let quote: String
    let mood: String?
    @StateObject private var themeManager = ThemeManager.shared

    private var backgroundColor: Color {
        guard let mood = mood else { return Color(UIColor.secondarySystemBackground) }
        switch mood.lowercased() {
        case "happy": return Color.green.opacity(0.2)
        case "sad": return Color.blue.opacity(0.2)
        case "angry": return Color.red.opacity(0.2)
        case "neutral": return Color.gray.opacity(0.2)
        case "surprised": return Color.orange.opacity(0.2)
        case "fearful": return Color.purple.opacity(0.2)
        case "disgusted": return Color.brown.opacity(0.2)
        default: return Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var accentColor: Color {
        guard let mood = mood else { return Color.primary }
        switch mood.lowercased() {
        case "happy": return .green
        case "sad": return .blue
        case "angry": return .red
        case "neutral": return .gray
        case "surprised": return .orange
        case "fearful": return .purple
        case "disgusted": return .brown
        default: return .primary
        }
    }

    private var quoteCardBackgroundColor: Color {
        themeManager.currentTheme == .dark
            ? Color(UIColor.secondarySystemBackground) // Dark mode
            : Color(UIColor.systemBackground)          // Light mode
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Daily Inspiration")
                    .font(.headline)
                    .foregroundColor(.primary) // Adaptive text color
                if let mood = mood {
                    Text("• \(mood)")
                        .font(.subheadline)
                        .foregroundColor(accentColor)
                }
                Spacer()
            }

            // Quote Display
            if !quote.isEmpty {
                Text(quote)
                    .font(.body)
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundColor(themeManager.currentTheme == .dark ? .white : .black) // Adaptive text color
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(quoteCardBackgroundColor) // Using dynamic quote card background color
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(accentColor.opacity(0.5), lineWidth: 1)
                            )
                    )
            } else {
                Text("Loading your daily inspiration...")
                    .foregroundColor(.secondary) // Adaptive secondary text color
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color(hex: themeManager.currentTheme == .dark ? "#000000" : "#fef2e4")) // Adaptive main background
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // Subtle shadow
    }
}
