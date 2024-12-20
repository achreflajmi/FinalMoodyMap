import SwiftUI

struct StudyProgressView: View {
    let studyPlan: StudyPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study Progress")
                .font(.headline)
            
            ForEach(studyPlan.sections) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(section.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
