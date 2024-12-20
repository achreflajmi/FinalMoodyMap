import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var language: String {
        didSet {
            UserDefaults.standard.set(language, forKey: "AppLanguage")
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {
        // Get saved language or default to system language
        if #available(iOS 16, *) {
            self.language = UserDefaults.standard.string(forKey: "Default localization") ??
                          Locale.current.language.languageCode?.identifier ??
                          "en"
        } else {
            self.language = UserDefaults.standard.string(forKey: "Default localization") ??
                          Locale.current.languageCode ??
                          "en"
        }
    }
    
    func localizedString(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to base localization if the selected language bundle is not found
            return NSLocalizedString(key, tableName: nil, bundle: .main, value: "", comment: "")
        }
        
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
