import Foundation

enum ILDateFormatting {
    static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static let iso8601NoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static func string(from date: Date) -> String {
        iso8601.string(from: date)
    }

    static func date(from string: String) -> Date? {
        iso8601.date(from: string) ?? iso8601NoFrac.date(from: string)
    }

    static func displayDate(fromISO string: String) -> String {
        guard let d = date(from: string) else { return string }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: d)
    }
}
