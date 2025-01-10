import Foundation

extension Date {
	public func toIso8601String() -> String {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
				
		func fourDigits(_ number: Int) -> String {
			String(format: "%04d", number)
		}
				
		func twoDigits(_ number: Int) -> String {
			String(format: "%02d", number)
		}
				
		func threeDigits(_ number: Int) -> String {
			String(format: "%03d", number)
		}
				
		let year = fourDigits(components.year ?? 0)
		let month = twoDigits(components.month ?? 0)
		let day = twoDigits(components.day ?? 0)
		let hour = twoDigits(components.hour ?? 0)
		let minute = twoDigits(components.minute ?? 0)
		let second = twoDigits(components.second ?? 0)
				
		// 将纳秒转换为毫秒和微秒
		let nanoseconds = components.nanosecond ?? 0
		let milliseconds = nanoseconds / 1_000_000
		let microseconds = (nanoseconds / 1_000) % 1_000
				
		let ms = threeDigits(milliseconds)
		let us = microseconds == 0 ? "" : threeDigits(microseconds)
				
		// 时区信息
		let timeZoneOffset = TimeZone.current.secondsFromGMT()
		if timeZoneOffset == 0 {
			return "\(year)-\(month)-\(day)T\(hour):\(minute):\(second).\(ms)\(us)Z"
		} else {
			return "\(year)-\(month)-\(day)T\(hour):\(minute):\(second).\(ms)\(us)Z"
		}
	}
		
	// 如果需要强制使用 UTC
	func toUtcIso8601String() -> String {
		var calendar = Calendar.current
		calendar.timeZone = TimeZone(secondsFromGMT: 0)!
				
		let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
				
		func fourDigits(_ number: Int) -> String {
			String(format: "%04d", number)
		}
				
		func twoDigits(_ number: Int) -> String {
			String(format: "%02d", number)
		}
				
		func threeDigits(_ number: Int) -> String {
			String(format: "%03d", number)
		}
				
		let year = fourDigits(components.year ?? 0)
		let month = twoDigits(components.month ?? 0)
		let day = twoDigits(components.day ?? 0)
		let hour = twoDigits(components.hour ?? 0)
		let minute = twoDigits(components.minute ?? 0)
		let second = twoDigits(components.second ?? 0)
				
		let nanoseconds = components.nanosecond ?? 0
		let milliseconds = nanoseconds / 1_000_000
		let microseconds = (nanoseconds / 1_000) % 1_000
				
		let ms = threeDigits(milliseconds)
		let us = microseconds == 0 ? "" : threeDigits(microseconds)
				
		return "\(year)-\(month)-\(day)T\(hour):\(minute):\(second).\(ms)\(us)Z"
	}
	
	public func checkTimeDifference(_ another: Date) -> Bool {
		let calendar = Calendar.current
		let selfComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
		let anotherComponets = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: another)
		return selfComponents.year == anotherComponets.year &&
		selfComponents.month == anotherComponets.month &&
		selfComponents.day == anotherComponets.day &&
		selfComponents.hour == anotherComponets.hour &&
		selfComponents.minute == anotherComponets.minute
	}
}

public extension String {
	func fromIso8601() -> Date? {
		// 尝试不同的格式
		let formats = [
			"yyyy-MM-dd'T'HH:mm:ssZ", // 2025-01-10T10:03:50Z
			"yyyy-MM-dd'T'HH:mm:ss.SSSZ", // 带毫秒
			"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", // 带微秒
			"yyyy-MM-dd HH:mm:ss.SSSSSSZ", // 空格分隔，带微秒
			"yyyy-MM-dd HH:mm:ssZ" // 空格分隔，无小数
		]
				
		let formatter = DateFormatter()
		formatter.locale = Locale.current
				
		for format in formats {
			formatter.dateFormat = format
			if let date = formatter.date(from: self) {
				return date
			}
		}
				
		// 如果上述都失败，尝试 ISO8601DateFormatter
		let iso8601Formatter = ISO8601DateFormatter()
		iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
				
		// 尝试原始字符串
		if let date = iso8601Formatter.date(from: self) {
			return date
		}
				
		// 尝试将空格替换为T的字符串
		let formattedString = self.replacingOccurrences(of: " ", with: "T")
		return iso8601Formatter.date(from: formattedString)
	}
}
