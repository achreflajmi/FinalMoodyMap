import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("selectedTheme") var selectedTheme: String = "system" {
        didSet {
            updateTheme()
        }
    }
    
    @Published var currentTheme: ColorScheme? = nil
    
    init() {
        updateTheme()
    }
    
    func updateTheme() {
        switch selectedTheme {
        case "light":
            currentTheme = .light
        case "dark":
            currentTheme = .dark
        default:
            currentTheme = .light // System default
        }
    }
}
