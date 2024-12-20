import Foundation

struct DateUtils {
    static let shared = DateUtils()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    func formatDisplayDate(_ dateString: String) -> String {
        if let date = isoFormatter.date(from: dateString) {
            return dateFormatter.string(from: date)
        }
        return dateString
    }
    
    func parseISODate(_ dateString: String) -> Date? {
        return isoFormatter.date(from: dateString)
    }
}
