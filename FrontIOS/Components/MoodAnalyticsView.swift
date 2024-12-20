import SwiftUI

struct MoodAnalyticsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header with title and time range selector
            HStack {
                Text("Mood Analytics")
                    .font(.headline)
                    .foregroundColor(Color.primary) // Adaptive color for text
                Spacer()
                Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
            }

            // Data section for the chart
            if !viewModel.moodEntries.isEmpty {
                VStack(spacing: 10) { // Use VStack to stack the cards vertically
                    // Emotion Distribution Card
                    MoodAnalyticsCard(
                        title: "Emotion Distribution",
                        content: {
                            MoodChartView(entries: viewModel.moodEntries)
                                .frame(height: 100) // Reduced height
                        }
                    )
                    .frame(maxWidth: .infinity, minHeight: 100) // Reduced height for the card

                    // Emotion Statistics Card
                    if let stats = viewModel.emotionStats {
                        MoodAnalyticsCard(
                            title: "Emotion Statistics",
                            content: {
                                MoodStatsView(stats: stats)
                            }
                        )
                        .frame(maxWidth: .infinity, minHeight: 100) // Reduced height for the card
                    }
                }
                .frame(maxWidth: .infinity) // Ensure both cards take the available width
            } else {
                Text("No mood data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(dynamicCardBackground)
                    .cornerRadius(10)
            }

        }
        .padding()
        .background(dynamicCardBackground) // Main adaptive background
        .cornerRadius(15)
        .shadow(radius: 10)
        .onChange(of: viewModel.selectedTimeRange) { newValue in
            viewModel.updateTimeRange(newValue)
        }
    }

    // Dynamic background color for the cards
    private var dynamicCardBackground: Color {
        Color(hex: themeManager.currentTheme == .dark ? "#000000" : "#fef2e4") // White for light mode
    }
}

struct MoodAnalyticsCard<Content: View>: View {
    let title: String
    let content: () -> Content
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.currentTheme == .dark ? .white : .black)

            content()
                .frame(maxHeight: .infinity) // Ensure content fits inside the card
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100) // Reduced height
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(radius: 5)
    }

    private var cardBackgroundColor: Color {
        themeManager.currentTheme == .dark
            ? Color(UIColor.secondarySystemBackground)
            : Color(UIColor.systemBackground)
    }
}

