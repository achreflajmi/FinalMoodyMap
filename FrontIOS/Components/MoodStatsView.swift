import SwiftUI

struct MoodStatsView: View {
    let stats: EmotionStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            
            Text("Total Emotions Detected: \(stats.totalEmotions)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Time Period:")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(DateUtils.shared.formatDisplayDate(stats.dateRange.start)) - \(DateUtils.shared.formatDisplayDate(stats.dateRange.end))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 10)
    }
}
