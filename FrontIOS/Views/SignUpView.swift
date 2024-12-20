import Foundation
import SwiftUI

struct SignupView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.colorScheme) var colorScheme // To detect dark/light mode

    // Track navigation state
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Use dynamic color for background based on the color scheme
                Color(hex: colorScheme == .dark ? "#1c1c1e" : "#fef2e4") // Background color
                    .edgesIgnoringSafeArea(.all)
                
                CircleBackgroundView()
                    .offset(x: -200, y: -400) // Position circles
                
                VStack(alignment: .leading, spacing: 20) {
                    // "Create Account" text
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: colorScheme == .dark ? "#ffffff" : "#000000"))
                        .padding(.top, 90)
                        .offset(x: 100, y: -20)
                    
                    // Logo Image
                    Image("logo") // Use the name of the image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .offset(x: 150, y: -20)
                    
                    VStack(spacing: 15) {
                        // Custom text fields for name, email, and password
                        CustomTextEntryField(
                            text: $viewModel.name,
                            placeholder: "Enter your Name",
                            textColor: colorScheme == .dark ? .white : .black
                        )
                        CustomTextEntryField(
                            text: $viewModel.email,
                            placeholder: "Enter your E-mail",
                            textColor: colorScheme == .dark ? .white : .black
                        )
                        CustomPasswordField(
                            text: $viewModel.password,
                            placeholder: "Enter password",
                            textColor: colorScheme == .dark ? .white : .black
                        )
                        
                        // Agree to terms toggle
                        HStack(alignment: .top) {
                            Toggle("", isOn: $viewModel.agreeToTerms)
                                .labelsHidden()
                            
                            Text("I agree to the ")
                                .foregroundColor(.primary) +
                            Text("Terms of Service and Privacy Policy")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 10)
                        
                        // Sign-up button
                        Button {
                            Task {
                                await viewModel.signUp()
                                if viewModel.isSignUpSuccessful {
                                    // Redirect to login screen after successful sign-up
                                    navigateToLogin = true
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign Up")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isValidForm ? Color(hex: colorScheme == .dark ? "4f3422" : "4f3422") : Color.gray)
                            .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading || !viewModel.isValidForm)
                        .padding(.top, 20)
                        
                        if !viewModel.signUpMessage.isEmpty {
                            Text(viewModel.signUpMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Login link
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Button(action: {
                                navigateToLogin = true
                            }) {
                                Text("Log in")
                                    .foregroundColor(Color(hex: colorScheme == .dark ? "#4f3422" : "#4f3422"))
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        Divider()
                            .padding(.vertical, 1)
                        
                        Text("Or continue with")
                            .foregroundColor(colorScheme == .dark ? .gray : .gray)
                            .font(.footnote)
                            .padding(.top, 1)
                        
                        HStack(spacing: 20) {
                            SocialLoginButton(imageName: "Gmail", backgroundColor: Color.white, action: {
                                // Google sign-up action
                            })
                            
                            SocialLoginButton(imageName: "Apple", backgroundColor: Color.white, action: {
                                // Apple sign-up action
                            })
                            
                            SocialLoginButton(imageName: "facebook", backgroundColor: Color(hex: colorScheme == .dark ? "#1877f2" : "#1877f2"), action: {
                                // Facebook sign-up action
                            })
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 30)
                    .background(Color.clear)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                
                // NavigationLink to Login View
                NavigationLink(
                    destination: LoginView(),
                    isActive: $navigateToLogin
                ) {
                    EmptyView()
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.isSignUpSuccessful ? "Success" : "Error"),
                    message: Text(viewModel.signUpMessage),
                    dismissButton: .default(Text("OK")) {
                        if viewModel.isSignUpSuccessful {
                            // Dismiss or navigate after success
                            navigateToLogin = true
                        }
                    }
                )
            }
            .gesture(
                DragGesture().onEnded { value in
                    if value.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
            .navigationBarHidden(true)
        }
    }
}

// Preview
#Preview {
    SignupView()
}
