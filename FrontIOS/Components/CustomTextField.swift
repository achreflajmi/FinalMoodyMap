import SwiftUI
import SwiftUI

struct CustomTextEntryField: View {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    var textColor: Color // Add this parameter for custom text color

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .foregroundColor(textColor) // Set text color based on dark/light mode
            .modifier(PlaceholderStyle()) // Apply the PlaceholderStyle
    }
}

struct CustomPasswordField: View {
    @Binding var text: String
    var placeholder: String
    var textColor: Color // Add this parameter for custom text color

    var body: some View {
        SecureField(placeholder, text: $text)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .foregroundColor(textColor) // Set text color based on dark/light mode
            .modifier(PlaceholderStyle()) // Apply the PlaceholderStyle
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
            )
            .foregroundColor(.black) // Set placeholder color to black
    }
}

struct PlaceholderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.black) // Change this color as per your requirement
            .onAppear {
                UITextField.appearance().tintColor = .black // Sets the tint color of the placeholder to black
            }
    }
}
