import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

private let networkService = NetworkService()

enum Field: Hashable{
    case email
    case password
}
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showErrorMessage = false
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var navigateToSignUp = false
    @State private var navigateToForgotPassword = false
    private let networkService = NetworkService()
    @Environment(\.colorScheme) var colorScheme // To detect dark/light mode
    @FocusState private var FocusField: Field?
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: colorScheme == .dark ? "#1c1c1e" : "#fef2e4") // Dynamic background for dark/light mode
                    .edgesIgnoringSafeArea(.all)
                    .gesture(
                                    TapGesture().onEnded {
                                        FocusField = nil
                                    }
                                )
                // Circles positioned in the top-left corner
                CircleBackgroundView()
                    .offset(x: -200, y: -400)

                VStack(alignment: .center, spacing: 20) {
                    Text("Welcome back!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: colorScheme == .dark ? "#ffffff" : "#000000"))
                        .padding(.top, 90)
                    
                        .scaledToFit()
                    Image("logo") // Use the name of the image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())

                    VStack(spacing: 30) {
                        CustomTextEntryField(
                            text: $viewModel.email,
                            placeholder: "Enter your E-mail",
                            keyboardType: .emailAddress,
                            textColor: colorScheme == .dark ? .black : .black
                        )
                        .disableAutocorrection(true)
                        .focused($FocusField, equals:.email)
                        .onTapGesture {
                            FocusField = nil
                        }
                        .foregroundColor(colorScheme == .dark ? .black : .black) // Adjust text color for dark/light mode
                        CustomPasswordField(
                            text: $viewModel.password,
                            placeholder: "Enter your password",
                            textColor: colorScheme == .dark ? .black : .black
                        )
                        .focused($FocusField, equals:.email)
                        .onTapGesture {
                            FocusField = nil
                        }
                        .foregroundColor(colorScheme == .dark ? .black : .black) // Adjust text color for dark/light mode

                        HStack {
                            Button(action: { viewModel.rememberMe.toggle() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: viewModel.rememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundColor(viewModel.rememberMe ? .blue : .gray)
                                        .font(.system(size: 20))
                                    Text("Remember Me")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                            }
                            Spacer()
                        }

                        Button(action: {
                            Task {
                                await viewModel.login()
                                if viewModel.isSignInSuccessful {
                                    authManager.isAuthenticated = true
                                    authManager.checkAuthenticationStatus()
                                } else {
                                    showErrorMessage = true
                                }
                            }
                        }) {
                            Text("Log in")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#4f3422"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoading)

                        if showErrorMessage {
                            Text(viewModel.signInMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }

                        Button(action: {
                            navigateToForgotPassword = true
                        }) {
                            Text("Forgot password?")
                                .font(.footnote)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Button(action: {
                                navigateToSignUp = true
                            }) {
                                Text("Sign up")
                                    .foregroundColor(Color(hex: colorScheme == .dark ? "#4f3422" : "#000000"))
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.bottom, 10)

                        Divider()

                        Text("Or continue with")
                            .foregroundColor(colorScheme == .dark ? .gray : .black)
                            .font(.footnote)

                        HStack(spacing: 20) {
                            SocialLoginButton(imageName: "Gmail", backgroundColor: Color.white, action: {
                                Task {
                                    await handleGoogleSignIn()
                                }
                            })
                            
                            SocialLoginButton(imageName: "Apple", backgroundColor: Color.white, action: {
                                // Apple login action
                            })
                            
                            
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 30)
                    .background(Color.clear)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .onAppear {
                        viewModel.loadSavedEmail()
                        configureGoogleSignIn()
                    }
                }

                NavigationLink(destination: ForgotPasswordView(), isActive: $navigateToForgotPassword) {
                    EmptyView()
                }
                NavigationLink(destination: SignupView(), isActive: $navigateToSignUp) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.isSignInSuccessful ? "Success" : "Error"),
                    message: Text(viewModel.signInMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }




    private func configureGoogleSignIn() {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: "752196072722-gornn57no13fp2b4h16m4vo66055bpna.apps.googleusercontent.com"
        )
    }
    
    private func handleGoogleSignIn() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No root view controller found")
            return
        }

        do {
            viewModel.isLoading = true
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                print("Failed to get ID token")
                await MainActor.run {
                    viewModel.signInMessage = "Failed to get Google authentication token"
                    viewModel.showAlert = true
                    viewModel.isLoading = false
                }
                return
            }
            
            let signInResponse = try await networkService.googleSignIn(idToken: idToken)
            
            await MainActor.run {
                viewModel.isSignInSuccessful = true
                viewModel.signInMessage = "Successfully signed in with Google"
                viewModel.showAlert = true
                viewModel.isLoading = false
            }
        } catch {
            await MainActor.run {
                if (error as NSError).code == GIDSignInError.canceled.rawValue {
                    viewModel.signInMessage = "Sign-in cancelled by user"
                } else if let networkError = error as? NetworkError {
                    switch networkError {
                    case .serverError(let message):
                        viewModel.signInMessage = message
                    case .unauthorized:
                        viewModel.signInMessage = "Unauthorized access"
                    default:
                        viewModel.signInMessage = "Failed to sign in with Google"
                    }
                } else {
                    viewModel.signInMessage = "Failed to sign in with Google: \(error.localizedDescription)"
                }
                viewModel.showAlert = true
                viewModel.isLoading = false
            }
        }
    }
}

// Button for Social Login
struct SocialLoginButton: View {
    var imageName: String
    var backgroundColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
        }
        .frame(width: 50, height: 50)
    }
}

// Circle background view to mimic the top-left circles in the design
struct CircleBackgroundView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#4f3422").opacity(0.3))
                .frame(width: 180, height: 180)
                .offset(x: 100, y: -50)

            Circle()
                .fill(Color(hex: "#4f3422").opacity(0.3))
                .frame(width: 180, height: 180)
                .offset(x: 26, y: 0)
        }
    }
}

// Preview
#Preview {
    LoginView()
}
