import SwiftUI

struct RecommendedEventsView: View {
    @StateObject private var themeManager = ThemeManager.shared

    let events: [Event]
    let mood: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Titre et humeur (le cas échéant)
            HStack {
                Text("Recommended Events")
                    .font(.headline)
                    .foregroundColor(.primary) // Couleur adaptative pour le texte
                if let mood = mood {
                    Text("• Based on \(mood)")
                        .font(.subheadline)
                        .foregroundColor(.secondary) // Couleur secondaire adaptative
                }
                Spacer()
            }
            
            // Liste des événements ou message d'absence
            if events.isEmpty {
                Text("No recommended events available")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(events) { event in
                        EventCard2(event: event, mood: mood ?? "")
                    }
                }
            }
        }
        .padding()
        .background(dynamicCardBackground) // Fond adaptatif
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    // Couleur de fond dynamique pour les cartes
    private var dynamicCardBackground: Color {
        Color(hex: themeManager.currentTheme == .dark ? "#000000" : "#fef2e4")    }
    
}
