import SwiftUI

struct EventCard2: View {
    let event: Event
    let mood: String
    @StateObject private var themeManager = ThemeManager.shared

    private var cardColor: Color {
        switch mood.lowercased() {
        case "happy": return Color.green.opacity(0.1)
        case "sad": return Color.blue.opacity(0.1)
        case "angry": return Color.red.opacity(0.1)
        case "neutral": return Color.gray.opacity(0.1)
        case "surprised": return Color.orange.opacity(0.1)
        case "fearful": return Color.purple.opacity(0.1)
        case "disgusted": return Color.brown.opacity(0.1)
        default: return Color(themeManager.currentTheme == .dark ? .black : .white)

        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: event.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)
                
                Text(event.formattedDate())
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.gray)
                    Text(event.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    private var cardBackgroundColor: Color {
        themeManager.currentTheme == .dark
            ? Color(UIColor.secondarySystemBackground)
            : Color(UIColor.systemBackground)
    }

}
