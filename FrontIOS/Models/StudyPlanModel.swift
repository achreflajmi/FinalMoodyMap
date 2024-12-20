import Foundation

struct StudyPlan: Codable {
    let plan: String
    let prompt: String
   
    struct Section: Identifiable {
        let id = UUID()
        let title: String
        let content: String
    }
   
    var sections: [Section] {
        // Split the plan into days
        let days = plan.components(separatedBy: "\n\n")
        return days.compactMap { day -> Section? in
            let dayContent = day.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !dayContent.isEmpty else { return nil }
            
            // Split the day into title and content
            let components = dayContent.components(separatedBy: ": ")
            guard components.count >= 2 else { return nil }
            
            let title = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let content = components[1...].joined(separator: ": ").trimmingCharacters(in: .whitespacesAndNewlines)
            
            return Section(title: title, content: content)
        }
    }
}
