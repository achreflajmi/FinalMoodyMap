import SwiftUI

struct AcademicPlannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: AcademicPlannerViewModel
    init() {
        // Initialize dependent view models
        let moodAssessmentViewModel = MoodAssessmentViewModel()
        let moodTrackingViewModel = MoodTrackingViewModel()

        // Inject them into the AcademicPlannerViewModel
        _viewModel = StateObject(wrappedValue: AcademicPlannerViewModel(
            moodAssessmentViewModel: moodAssessmentViewModel,
            moodTrackingViewModel: moodTrackingViewModel
        ))
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#fef2e4")
                .edgesIgnoringSafeArea(.all)

            CircleBackgroundView()
                .offset(x: -200, y: -400)

            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Academic Planner")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#ffffff" : "#000000"))


                        .padding(.top, 60)
                        .frame(maxWidth: .infinity, alignment: .top)

                    // Date Picker
                    DatePickerView(examDate: $viewModel.examDate)
                        .padding()

                    // Generate Plan Button
                    Button(action: {
                        Task {
                            await viewModel.generatePlan()
                        }
                    }) {
                        HStack {
                                              Image(systemName: "doc.text.magnifyingglass")
                                              Text("Generate Study Plan")
                                          }
                                          .foregroundColor(.white)
                                          .padding()
                                          .background(Color(hex: "#4f3422"))
                                          .cornerRadius(10)
                                      }

                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else if let plan = viewModel.studyPlan {
                        StudyPlanSectionsView(plan: plan)
                    }

                    // Study Timer
                    StudyTimerView(viewModel: viewModel)
                        .padding()
                }
                .padding()
            }
        }
    }
}

struct DatePickerView: View {
    @Binding var examDate: Date
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack {
            DatePicker(
                "Exam Date",
                selection: $examDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .accentColor(Color(hex: themeManager.currentTheme == .dark ? "#ffdb3a" : "#4f3422")) // Change accent color based on theme
            .padding()
            .background(Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#ffffff")) // Change background color based on theme
            .cornerRadius(15)
            .shadow(radius: 5)
        }
        .preferredColorScheme(themeManager.currentTheme) // Apply the theme to the view
    }
}


struct StudyPlanSectionsView: View {
    let plan: StudyPlan
    @StateObject private var taskManager = TaskManager()
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 20) {
            ForEach(plan.sections) { section in
                VStack(alignment: .leading, spacing: 15) {
                    Text(section.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#ffffff" : "#4f3422"))

                        .padding(.bottom, 5)

                    let tasks = section.content
                        .components(separatedBy: "\n")
                        .filter { !$0.isEmpty }
                        .map { $0.trimmingCharacters(in: .whitespaces) }

                    ForEach(tasks, id: \.self) { task in
                        TaskCard(task: task, isCompleted: taskManager.isTaskCompleted(task))
                    }
                }
                .padding()
                .background(Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#ffffff"))
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }
        .padding(.horizontal)
    }
}


struct TaskCard: View {
    let task: String
    @State var isCompleted: Bool
    @ObservedObject private var taskManager = TaskManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: {
                isCompleted.toggle()
                taskManager.toggleTask(task)
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? Color(hex: "#ffdb3a") : .gray)
                    .font(.system(size: 20))
            }

            Text(task.replacingOccurrences(of: "- ", with: ""))
                .font(.body)
                .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#dcdcdc" : "#000000"))
                .strikethrough(isCompleted, color: .gray)
                .animation(.easeInOut, value: isCompleted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(hex: themeManager.currentTheme == .dark ? "#333333" : "#f8f8f8"))
        .cornerRadius(8)
    }
}


struct SectionCard: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#ffdb3a" : "#4f3422")) // Adjust text color based on theme

            Text(content)
                .font(.body)
                .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#dcdcdc" : ".black.opacity(0.7)")) // Adjust content color based on theme
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#ffffff")) // Background color of the overall container based
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct StudyTimerView: View {
    @ObservedObject var viewModel: AcademicPlannerViewModel
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 15) {
            Text(viewModel.formattedTime())
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color(hex: themeManager.currentTheme == .dark ? "#ffffff" : "#4f3422"))
                .monospacedDigit()

            HStack(spacing: 20) {
                TimerButton(
                    title: viewModel.isTimerRunning ? "Stop" : "Start",
                    systemImage: viewModel.isTimerRunning ? "stop.fill" : "play.fill",
                    action: {
                        if viewModel.isTimerRunning {
                            viewModel.stopTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }
                )

                TimerButton(
                    title: "Reset",
                    systemImage: "arrow.clockwise",
                    action: {
                        viewModel.resetTimer()
                    }
                )
            }
        }
        .padding()
        .background(Color(hex: themeManager.currentTheme == .dark ? "#1a1a1a" : "#ffffff")) // Background color based on theme
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct TimerButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(hex: themeManager.currentTheme == .dark ? "#4f3422" : "#4f3422")) // Adjust background color based on theme
            .cornerRadius(10)
        }
    }
}

#Preview {
    AcademicPlannerView()
}
