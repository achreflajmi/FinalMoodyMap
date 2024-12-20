import SwiftUI

public struct ResetPasswordView: View {
    @State private var resetCode = ""
    @State private var newPassword = ""
    @State private var isError = false
    @State private var errorMessage = ""
    @State private var isPasswordReset = false
    @State private var isCodeVerified = false
    @State private var navigateToLogin = false  // Add state to track navigation
    let userId: String
    
    private var networkService = NetworkService()
    @Environment(\.colorScheme) var colorScheme // To detect dark/light mode

    public init(userId: String) {
        self.userId = userId
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: colorScheme == .dark ? "#1c1c1e" : "#fef2e4")
                    .edgesIgnoringSafeArea(.all)
                
                CircleBackgroundView()
                    .offset(x: -200, y: -400)

                VStack(alignment: .leading, spacing: 20) {
                    Text(isCodeVerified ? "Set New Password" : "Enter Reset Code")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.top, 90)
                        .offset(x: 100, y: -20)
                    
                    VStack(spacing: 30) {
                        if !isCodeVerified {
                            CustomTextEntryField(
                                text: $resetCode,
                                placeholder: "Enter reset code",
                                keyboardType: .numberPad,
                                textColor: colorScheme == .dark ? .white : .black
                            )
                            
                            Button(action: {
                                Task {
                                    await verifyCode()
                                }
                            }) {
                                Text("Verify Code")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: colorScheme == .dark ? "#4f3422" : "#4f3422"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            CustomPasswordField(
                                text: $newPassword,
                                placeholder: "Enter new password",
                                textColor: colorScheme == .dark ? .white : .black
                            )
                            
                            Button(action: {
                                Task {
                                    await resetPassword()
                                }
                            }) {
                                Text("Reset Password")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: colorScheme == .dark ? "#4f3422" : "#4f3422"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }

                        if isError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }

                        if isPasswordReset {
                            Text("Password successfully reset.")
                                .foregroundColor(.green)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 30)
                    .background(Color.clear)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
            }
            .navigationBarHidden(true)
            // NavigationLink to LoginView when navigateToLogin becomes true
            .background(
                NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                    EmptyView()
                }
            )
            // Trigger delayed navigation when the password is reset
            .onChange(of: isPasswordReset) { _ in
                if isPasswordReset {
                    // Trigger navigation with delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        navigateToLogin = true
                    }
                }
            }
        }
    }

    private func verifyCode() async {
        do {
            try await networkService.verifyResetCode(userId: userId, resetCode: resetCode)
            isCodeVerified = true
            isError = false
        } catch {
            isError = true
            errorMessage = error.localizedDescription
        }
    }

    private func resetPassword() async {
        do {
            try await networkService.resetPassword(userId: userId, newPassword: newPassword)
            isPasswordReset = true
            isError = false
        } catch {
            isError = true
            errorMessage = error.localizedDescription
        }
    }
}
