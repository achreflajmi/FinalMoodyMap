import SwiftUI

struct ThemeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack(spacing: 0) {
                // Light mode side
                HStack(spacing: 4) {
                    Image(systemName: "sun.max.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            configuration.isOn ? .gray : Color(red: 254/255, green: 242/255, blue: 228/255), // Convert hex to RGB
                            configuration.isOn ? .gray.opacity(0.5) : Color(red: 254/255, green: 242/255, blue: 228/255) // Convert hex to RGB
                        )
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(configuration.isOn ? Color.clear : Color(hex: "#4f3422"))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                // Dark mode side
                HStack(spacing: 4) {
                    Image(systemName: "moon.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            configuration.isOn ? .white : .gray,
                            configuration.isOn ? .white : .gray.opacity(0.5)
                        )
                        .font(.system(size: 14))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(configuration.isOn ? Color(hex: "#4f3422") : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .animation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0), value: configuration.isOn)
        }
    }
}

#Preview {
    ProfileView(authManager: AuthenticationManager.shared)
}
