import Foundation

@MainActor
class AcademicPlannerViewModel: ObservableObject {
    @Published var examDate = Date()
    @Published var studyPlan: StudyPlan?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var timerSeconds = 0
    @Published var isTimerRunning = false
    private var timer: Timer?
    
    private let moodAssessmentViewModel: MoodAssessmentViewModel
    private let moodTrackingViewModel: MoodTrackingViewModel
    
    init(moodAssessmentViewModel: MoodAssessmentViewModel, moodTrackingViewModel: MoodTrackingViewModel) {
        self.moodAssessmentViewModel = moodAssessmentViewModel
        self.moodTrackingViewModel = moodTrackingViewModel
    }
    
    private func getUserTypeAndEmotion() -> (userType: String, emotion: String) {
        // Get user type from MoodAssessmentViewModel
        let userType = moodAssessmentViewModel.userType.isEmpty ?
            moodAssessmentViewModel.getResultMessage() :
            moodAssessmentViewModel.userType
        
        // Get emotion from MoodTrackingViewModel
        let emotion = moodTrackingViewModel.detectedEmotion.isEmpty ?
            "Neutral" :
            moodTrackingViewModel.detectedEmotion
        
        return (userType, emotion)
    }
    
    @MainActor
    func generatePlan() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let examDateString = dateFormatter.string(from: examDate)
            
            let (userType, emotion) = getUserTypeAndEmotion()
            
            print("User Type: \(userType)")
            print("Detected Emotion: \(emotion)")
            print("Exam Date: \(examDateString)")
            
            let plan = try await StudyPlanService.shared.generateStudyPlan(
                userType: userType,
                emotion: emotion,
                examDate: examDateString
            )
            
            self.studyPlan = plan
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    // Timer functions remain unchanged
    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.timerSeconds += 1
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        stopTimer()
        timerSeconds = 0
    }
    
    func formattedTime() -> String {
        let hours = timerSeconds / 3600
        let minutes = (timerSeconds % 3600) / 60
        let seconds = timerSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
