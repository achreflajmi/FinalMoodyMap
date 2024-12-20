import SwiftUI

struct MoodAssessmentView: View {
    @StateObject private var viewModel = MoodAssessmentViewModel()
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.colorScheme) var colorScheme // To detect dark/light mode
    
    var body: some View {
        if viewModel.quizFinished {
            ResultView(userType: viewModel.userType)
                .onChange(of: viewModel.shouldNavigateToHome) { shouldNavigate in
                    if shouldNavigate {
                        authManager.needsAssessment = false
                    }
                }
        
        } else {
            QuizView(viewModel: viewModel)
        }
    }
}

struct QuizView: View {
    @ObservedObject var viewModel: MoodAssessmentViewModel
    @Environment(\.colorScheme) var colorScheme // To detect dark/light mode
    
    var body: some View {
        ZStack {
            Color(
                hex: colorScheme == .dark ? "#1c1c1e" : "#fef2e4"
            ) // Dynamic background for dark/light mode
            .ignoresSafeArea()
            
            CircleBackgroundView() // Reuse the same CircleBackgroundView
                .offset(x: -200, y: -400)  // Adjusting position like in the Login View
            
            VStack(spacing: 120) {
                Text(viewModel.questions[viewModel.currentQuestionIndex].text)
                    .font(.system(size: 26, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .offset(y: 80)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.questions[viewModel.currentQuestionIndex].answers.enumerated()), id: \.offset) { index, answer in
                            AnswerCardView(
                                answer: answer,
                                isSelected: viewModel.selectedAnswerIndex == index,
                                action: { viewModel.selectedAnswerIndex = index }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: viewModel.handleAnswerSelected) {
                    Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Submit" : "Next")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#4f3422")) // White for dark mode, other color for light mode
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(hex: colorScheme == .dark ? "#4f3422" : "#fef2e4")) // Button background varies by mode
                        .cornerRadius(12)
                        .shadow(radius: 8)
                }
                .disabled(viewModel.selectedAnswerIndex == -1)
                .padding(.horizontal)
                .padding(.bottom)
                .offset(y: -80)
            }
        }
    }
}
struct Question {
    let text: String
    let answers: [Answer]
}

struct Answer {
    let text: String
    let score: Int
}

class MoodAssessmentData {
    static let questions = [
        Question(text: "How do you feel about your overall emotional state right now?", answers: [
            Answer(text: "Very Distressed", score: 1),
            Answer(text: "Somewhat Distressed", score: 3),
            Answer(text: "Neutral", score: 5),
            Answer(text: "Calm and Positive", score: 10)
        ]),
        Question(text: "How energized do you feel to handle your daily activities?", answers: [
            Answer(text: "Completely Drained", score: 1),
            Answer(text: "Low Energy", score: 3),
            Answer(text: "Moderate Energy", score: 5),
            Answer(text: "Fully Energized", score: 10)
        ]),
        Question(text: "How would you rate your ability to concentrate on tasks today?", answers: [
            Answer(text: "Unable to Focus", score: 1),
            Answer(text: "Difficulty Staying Focused", score: 3),
            Answer(text: "Moderately Focused", score: 5),
            Answer(text: "Fully Focused and Alert", score: 10)
        ]),
        Question(text: "How overwhelmed or stressed are you feeling right now?", answers: [
            Answer(text: "Extremely Overwhelmed", score: 1),
            Answer(text: "Moderately Stressed", score: 3),
            Answer(text: "Somewhat Calm", score: 5),
            Answer(text: "Relaxed and Stress-Free", score: 10)
        ]),
        Question(text: "How would you describe your physical condition today (pain, fatigue, illness)?", answers: [
            Answer(text: "Severe Discomfort", score: 1),
            Answer(text: "Minor Aches or Fatigue", score: 3),
            Answer(text: "Neutral or Average", score: 5),
            Answer(text: "Healthy and Comfortable", score: 10)
        ]),
        Question(text: "How confident do you feel about achieving your goals today?", answers: [
            Answer(text: "No Confidence", score: 1),
            Answer(text: "Some Confidence", score: 3),
            Answer(text: "Moderately Confident", score: 5),
            Answer(text: "Fully Confident and Capable", score: 10)
        ]),
        Question(text: "How restorative and refreshing was your sleep last night?", answers: [
            Answer(text: "Not Restorative At All", score: 1),
            Answer(text: "Partially Restorative", score: 3),
            Answer(text: "Adequate", score: 5),
            Answer(text: "Fully Restorative and Refreshing", score: 10)
        ]),
        Question(text: "How well are you managing your emotions right now?", answers: [
            Answer(text: "Extremely Poorly", score: 1),
            Answer(text: "Somewhat Poorly", score: 3),
            Answer(text: "Neutral or Stable", score: 5),
            Answer(text: "Very Well and Balanced", score: 10)
        ]),
        Question(text: "How productive do you feel your day has been so far?", answers: [
            Answer(text: "Not Productive At All", score: 1),
            Answer(text: "Somewhat Productive", score: 3),
            Answer(text: "Moderately Productive", score: 5),
            Answer(text: "Highly Productive", score: 10)
        ]),
        Question(text: "How would you rate your current level of happiness and satisfaction?", answers: [
            Answer(text: "Extremely Dissatisfied", score: 1),
            Answer(text: "Somewhat Dissatisfied", score: 3),
            Answer(text: "Neutral or Content", score: 5),
            Answer(text: "Very Happy and Satisfied", score: 10)
        ])
    ]
   
    static let maxScore = questions.count * 10
}

struct ResultView: View {
    let userType: String
    @Environment(\.colorScheme) var colorScheme // To detect dark/light mode

    var body: some View {
        ZStack {
            Color(
                hex: colorScheme == .dark ? "#1c1c1e" : "#fef2e4"
            ) // Dynamic background for dark/light mode
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Your Assessment Result:")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#4f3422")) // Adjust text color for dark/light mode

                Text("Your User Type: \(userType)")
                    .font(.system(size: 20))
                    .foregroundColor(colorScheme == .dark ? .white : .black) // Adjust text color for dark/light mode
                    .padding(.top, 20)

                Text("Redirecting to home...")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .gray : .gray) // Adjust text color for dark/light mode
                    .padding(.top, 20)
            }
            .padding()
        }
    }
}


#Preview {
    MoodAssessmentView()
}
