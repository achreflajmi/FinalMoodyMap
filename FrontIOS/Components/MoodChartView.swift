import SwiftUI
import Charts

struct MoodChartView: View {
    let entries: [MoodEntry]
    
    private let emotionColors: [String: Color] = [
        "Happy": .green,
        "Sad": .blue,
        "Angry": .red,
        "Neutral": .gray,
        "Surprised": .orange,
        "Fearful": .purple,
        "Disgusted": .brown
    ]
    
    // Compute total counts for each emotion
    private var emotionTotals: [(emotion: String, count: Int)] {
        Dictionary(grouping: entries, by: { $0.emotion })
            .map { (emotion, entries) in
                (emotion: emotion, count: entries.reduce(0) { $0 + $1.count })
            }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
      
            Chart {
                ForEach(emotionTotals, id: \.emotion) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Emotion", item.emotion)
                    )
                    .foregroundStyle(emotionColors[item.emotion] ?? .gray)
                    .annotation(position: .trailing) {
                        Text("\(item.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(height: min(CGFloat(emotionTotals.count) * 40 + 50, 300))
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(preset: .aligned)
            }
        }
    }
}
