import Foundation

// Define a protocol similar to LookupMessages
public protocol TimeAgoMessages {
	func prefixAgo() -> String
	func suffixAgo() -> String
	func lessThanOneMinute(seconds: Int) -> String
	func aboutAMinute(minutes: Int) -> String
	func minutes(minutes: Int) -> String
	func aboutAnHour(minutes: Int) -> String
	func hours(hours: Int) -> String
	func aDay(hours: Int) -> String
	func days(days: Int) -> String
	func aboutAMonth(days: Int) -> String
	func months(months: Int) -> String
	func aboutAYear(years: Int) -> String
	func years(years: Int) -> String
	func wordSeparator() -> String
}

// Implement the protocol
public struct EnglishTimeAgoMessages: TimeAgoMessages {
	public init() {}
	public func prefixAgo() -> String { return "" }
	public func suffixAgo() -> String { return " ago" }
	public func lessThanOneMinute(seconds: Int) -> String { return "just now" }
	public func aboutAMinute(minutes: Int) -> String { return "a minute ago" }
	public func minutes(minutes: Int) -> String { return "\(minutes) minutes ago" }
	public func aboutAnHour(minutes: Int) -> String { return "an hour ago" }
	public func hours(hours: Int) -> String { return "\(hours) hours ago" }
	public func aDay(hours: Int) -> String { return "a day ago" }
	public func days(days: Int) -> String { return "\(days) days" }
	public func aboutAMonth(days: Int) -> String { return "a month ago" }
	public func months(months: Int) -> String { return "\(months) months ago" }
	public func aboutAYear(years: Int) -> String { return "a year ago" }
	public func years(years: Int) -> String { return "\(years) years ago" }
	public func wordSeparator() -> String { return " " }
}

// Function to calculate time ago
public func timeAgo(from date: Date, messages: TimeAgoMessages = EnglishTimeAgoMessages()) -> String {
	let now = Date.now.addingTimeInterval(-TimeInterval(TimeZone.current.secondsFromGMT()))
	let secondsAgo = Int(now.timeIntervalSince(date))

	let minute = 60
	let hour = 60 * minute
	let day = 24 * hour
	let month = 30 * day
	let year = 365 * day

	if secondsAgo < minute {
		return messages.lessThanOneMinute(seconds: secondsAgo)
	} else if secondsAgo < 2 * minute {
		return messages.aboutAMinute(minutes: 1)
	} else if secondsAgo < hour {
		return messages.minutes(minutes: secondsAgo / minute)
	} else if secondsAgo < 2 * hour {
		return messages.aboutAnHour(minutes: 1)
	} else if secondsAgo < day {
		return messages.hours(hours: secondsAgo / hour)
	} else if secondsAgo < 2 * day {
		return messages.aDay(hours: 1)
	} else if secondsAgo < month {
		return messages.days(days: secondsAgo / day)
	} else if secondsAgo < 2 * month {
		return messages.aboutAMonth(days: 1)
	} else if secondsAgo < year {
		return messages.months(months: secondsAgo / month)
	} else if secondsAgo < 2 * year {
		return messages.aboutAYear(years: 1)
	} else {
		return messages.years(years: secondsAgo / year)
	}
}
