import Foundation
import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isError = false
    @State private var errorMessage = ""
    @State private var isEmailSent = false
    @State private var navigateToResetPassword = false
    @State private var userId: String? = nil
    @Environment(\.colorScheme) var colorScheme // To detect dark/light mode

    private var networkService = NetworkService()

    var body: some View {
        ZStack {
            Color(hex: colorScheme == .dark ? "#1c1c1e" : "#fef2e4")
                .edgesIgnoringSafeArea(.all) // Dynamic background for dark/light mode

            CircleBackgroundView()
                .offset(x: -200, y: -400)

            VStack(alignment: .leading, spacing: 20) {
                Text("Forgot Password?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 90)
                    .offset(x: 100, y: -20)

                VStack(spacing: 30) {
                    CustomTextEntryField(
                        text: $email,
                        placeholder: "Enter your email",
                        keyboardType: .emailAddress,
                        textColor: colorScheme == .dark ? .black : .black
                    )

                    Button(action: {
                        Task {
                            await sendResetCode()
                        }
                    }) {
                        Text("Send Reset Code")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: colorScheme == .dark ? "#4f3422" : "#4f3422"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    if isError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }

                    if isEmailSent {
                        Text("Password reset code sent to \(email)")
                            .foregroundColor(.green)
                            .padding(.top, 10)
                    }

                    NavigationLink(
                        destination: ResetPasswordView(userId: userId ?? ""),
                        isActive: $navigateToResetPassword
                    ) {
                        EmptyView()
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
    }

    private func sendResetCode() async {
        do {
            let response = try await networkService.forgotPassword(email: email)
            userId = response.userId
            isEmailSent = true
            isError = false
            navigateToResetPassword = true
        } catch {
            isError = true
            errorMessage = error.localizedDescription
        }
    }
}

#Preview{
    ForgotPasswordView()
}
