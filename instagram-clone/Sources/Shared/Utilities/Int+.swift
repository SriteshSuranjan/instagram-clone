import Foundation

extension Int {
	public func compactShort(locale: Locale = .current) -> String {
		// 如果数字小于 9999，使用普通格式
		if self <= 9_999 {
			return String(self)
		}
				
		// 创建紧凑格式的 NumberFormatter
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = locale
				
		// 根据数字大小选择合适的格式
		if self >= 1_000_000 {
			formatter.numberStyle = .decimal
			let num = Double(self) / 1_000_000
			formatter.maximumFractionDigits = 1
			let formatted = formatter.string(from: NSNumber(value: num)) ?? "\(num)"
			return "\(formatted)M"
		} else if self >= 1_000 {
			formatter.numberStyle = .decimal
			let num = Double(self) / 1_000
			formatter.maximumFractionDigits = 1
			let formatted = formatter.string(from: NSNumber(value: num)) ?? "\(num)"
			return "\(formatted)K"
		}
				
		return String(self)
	}
}
