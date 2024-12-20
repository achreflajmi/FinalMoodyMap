//
//  FrontIOSApp.swift
//  FrontIOS
//
//  Created by guesmiFiras on 8/11/2024.
//

import SwiftUI
import GoogleSignIn

@main
struct FrontIOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    
    var body: some Scene {
        WindowGroup {
            
            NavigationStack {
                if authManager.isAuthenticated {
                    if authManager.needsAssessment {
                        MoodAssessmentView()
                            .environmentObject(authManager)
                            .environmentObject(themeManager)
                            .preferredColorScheme(themeManager.currentTheme)
                    } else {
                        BottomNavBarView(authManager: authManager)
                        .environmentObject(themeManager)
                        .preferredColorScheme(themeManager.currentTheme)
                    }
                } else {
                    LoginView()
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.currentTheme)
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
