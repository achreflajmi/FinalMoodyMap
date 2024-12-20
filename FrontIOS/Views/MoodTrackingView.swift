import SwiftUI
import PhotosUI
import AVFoundation

struct MoodTrackingView: View {
    @StateObject private var viewModel = MoodTrackingViewModel()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Background based on color scheme
            Color(hex: colorScheme == .dark ? "#1a1a1a" : "#fef2e4")
                .edgesIgnoringSafeArea(.all)

            CircleBackgroundView()
                .offset(x: -200, y: -400)

            VStack {
                // Title
                Text("Mood Tracking")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: colorScheme == .dark ? "#ffffff" : "#000000"))
                    .padding(.top, 60)
                    .frame(maxWidth: .infinity, alignment: .top)

                Spacer()

                // Display selected image
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(15)
                        .padding()
                } else {
                    Text("Select an image to detect your mood!")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                }

                Spacer()

                // Button for selecting a photo
                Button(action: {
                    showImageSourceSelection()
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Select or Take Photo")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(hex: colorScheme == .dark ? "#4f3422" : "#4f3422"))
                    .cornerRadius(10)
                }

                // Detect emotion button
                if let image = selectedImage {
                    Button(action: {
                        viewModel.detectEmotion(from: image)
                    }) {
                        HStack {
                            Image(systemName: "face.smiling")
                            Text("Detect Emotion")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: colorScheme == .dark ? "#4f3422" : "#4f3422"))
                        .cornerRadius(10)
                    }
                    .padding(.top)
                }

                Spacer()

                // Detected emotion with emoji and advice
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if !viewModel.detectedEmotion.isEmpty {
                    DetectedEmotionView(emotion: viewModel.detectedEmotion)
                        .padding(.top, 20)
                }

                // Error message
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .padding(.top, 10)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker2(sourceType: sourceType, selectedImage: $selectedImage)
            }
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(title: Text("Permission Required"),
                  message: Text(permissionMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    private func showImageSourceSelection() {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)

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
        switch status {
        case .authorized, .limited:
            completion()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
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


struct DetectedEmotionView: View {
    let emotion: String
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 10) {
            // Emotion Icon and Title
            HStack(spacing: 10) {
                Text(getEmoji(for: emotion))
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#ffdb3a" : "#4f3422"))

                Text(emotion.capitalized)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#ffdb3a" : "#4f3422"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: themeManager.currentTheme == .dark ? "#4f3422" : "#ffedd5"),
                        Color(hex: themeManager.currentTheme == .dark ? "#ffedd5" : "#fec89a")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(15)
            .shadow(radius: 8)

            // Description Text
            Text(getDescription(for: emotion))
                .font(.body)
                .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#ffffff" : "#000000").opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .padding(20)
        .background(Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#ffffff"))
        .cornerRadius(15)
        .shadow(radius: 10)
    }

    private func getEmoji(for emotion: String) -> String {
        switch emotion.lowercased() {
        case "angry": return "😡"
        case "fear": return "😨"
        case "happy": return "😄"
        case "sad": return "😢"
        case "surprise": return "😲"
        case "neutral": return "😐"
        default: return "❓"
        }
    }

    private func getDescription(for emotion: String) -> String {
        switch emotion.lowercased() {
        case "angry":
            return "It's okay to feel angry sometimes. Take deep breaths, and consider stepping away from the situation to calm down."
        case "fear":
            return "Fear can be overwhelming. Try grounding techniques and remind yourself that you are safe."
        case "happy":
            return "You're feeling happy! Spread positivity and enjoy this wonderful moment."
        case "sad":
            return "Feeling sad is natural. Talk to someone you trust, and remember that this too shall pass."
        case "surprise":
            return "Surprises can be exciting or shocking. Embrace the unexpected and adapt as needed."
        case "neutral":
            return "You're feeling neutral. Take this moment to reflect or relax without stress."
        default:
            return "Emotion not recognized. Stay curious and keep exploring!"
        }
    }
}



struct ImagePicker2: UIViewControllerRepresentable {
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
        let parent: ImagePicker2

        init(_ parent: ImagePicker2) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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

#Preview {
    MoodTrackingView()
}
