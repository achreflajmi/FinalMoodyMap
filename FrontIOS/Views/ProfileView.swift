import SwiftUI
import PhotosUI
import AVFoundation

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager: AuthenticationManager
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var navigateToLogin = false

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }

    var body: some View {
        ZStack {
            Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#fef2e4")
                .edgesIgnoringSafeArea(.all)

            CircleBackgroundView()
                .offset(x: -200, y: -400)

            VStack {
                Spacer()

                VStack(alignment: .center, spacing: 20) {
                    // Profile image
                    Image(uiImage: viewModel.profileImage ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .onTapGesture {
                            showImageSourceSelection()
                        }
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))

                    Text(viewModel.userName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(viewModel.userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextField(localizationManager.localizedString("Enter your name"), text: $viewModel.userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 10) // Adjust padding

                    TextField(localizationManager.localizedString("Enter your email"), text: $viewModel.userEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 10) // Adjust padding
                        .disabled(true)

                    // Theme Toggle in a Card
                    Card {
                        HStack {
                            Text(localizationManager.localizedString("Light"))
                                .foregroundColor(themeManager.currentTheme == .dark ? .gray : .primary)

                            Toggle("Theme", isOn: Binding(
                                get: { themeManager.currentTheme == .dark },
                                set: { themeManager.currentTheme = $0 ? .dark : .light }
                            ))
                            .toggleStyle(ThemeToggleStyle())
                            .padding()

                            Text(localizationManager.localizedString("Dark"))
                                .foregroundColor(themeManager.currentTheme == .dark ? .primary : .gray)
                        }
                        .padding(.horizontal, 10) // Adjust padding
                    }
                    .padding(.horizontal, 10) // Adjust padding

                    Button(action: {
                        Task {
                            await viewModel.updateProfile(name: viewModel.userName, email: viewModel.userEmail, image: viewModel.profileImage)
                        }
                    }) {
                        Text(localizationManager.localizedString("Save Changes"))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#4f3422"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, -10) // Reduce padding

                }
                .padding()

                Button(action: {
                    Task {
                        await viewModel.logout(authManager: authManager)
                        navigateToLogin = true
                    }
                }) {
                    Text(localizationManager.localizedString("logout"))
                        .fontWeight(.semibold)
                        .frame(width: 330)
                        .padding()
                        .background(Color(hex: "#4f3422"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle(localizationManager.localizedString("profile"))
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
        .preferredColorScheme(themeManager.currentTheme)
        .task {
            await viewModel.fetchUserDetails()
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(title: Text("Permission Required"),
                  message: Text(permissionMessage),
                  dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $viewModel.profileImage)
        }
    }

    private func showImageSourceSelection() {
        let alert = UIAlertController(title: "Select Profile Picture", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            checkCameraPermission {
                sourceType = .camera
                showImagePicker = true
            }
        })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            checkPhotoLibraryPermission {
                sourceType = .photoLibrary
                showImagePicker = true
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }

    private func checkCameraPermission(completion: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    completion()
                } else {
                    showPermissionAlert(message: "Camera access is required to take a photo.")
                }
            }
        case .denied:
            showPermissionAlert(message: "Please enable camera access in Settings.")
        case .restricted:
            showPermissionAlert(message: "Camera access is restricted on this device.")
        @unknown default:
            break
        }
    }

    private func checkPhotoLibraryPermission(completion: @escaping () -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        print("Current photo library status: \(status.rawValue)")
        switch status {
        case .authorized, .limited:
            completion()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                print("New photo library status: \(newStatus.rawValue)")
                if newStatus == .authorized || newStatus == .limited {
                    completion()
                } else {
                    showPermissionAlert(message: "Photo library access is required to select a photo.")
                }
            }
        case .denied:
            showPermissionAlert(message: "Please enable photo library access in Settings.")
        case .restricted:
            showPermissionAlert(message: "Photo library access is restricted on this device.")
        @unknown default:
            break
        }
    }

    private func showPermissionAlert(message: String) {
        permissionMessage = message
        showPermissionAlert = true
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct Card<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack {
            content()
        }
        
        .padding(-5)
        .background(Color.clear) // Change to your theme's background color
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    ProfileView(authManager: AuthenticationManager.shared)
}
