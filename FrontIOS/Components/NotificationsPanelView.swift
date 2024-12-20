import SwiftUI

struct NotificationsPanelView: View {
    let notifications: [Notification]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Notifications")
                .font(.headline)
            
            if notifications.isEmpty {
                Text("No new notifications")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(notifications) { notification in
                    NotificationCard(notification: notification)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct NotificationCard: View {
    let notification: Notification
    
    var body: some View {
        HStack(spacing: 12) {
            notificationIcon
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(formatDate(notification.date))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
    
    private var notificationIcon: some View {
        Image(systemName: iconName)
            .foregroundColor(iconColor)
            .font(.system(size: 24))
    }
    
    private var iconName: String {
        switch notification.type {
        case .exam: return "book.fill"
        case .event: return "calendar"
        case .mood: return "face.smiling"
        case .general: return "bell.fill"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .exam: return .blue
        case .event: return .green
        case .mood: return .orange
        case .general: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
