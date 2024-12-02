import Foundation
import SwiftUI
import AppUI
import Shared

public struct UserProfileStatistics: View {
	let name: String
	@Binding var value: Int
	let onTap: () -> Void
	@Environment(\.textTheme) var textTheme
	public init(name: String, value: Binding<Int>, onTap: @escaping () -> Void) {
		self.name = name
		self._value = value
		self.onTap = onTap
	}
	public var body: some View {
		Button(action: onTap) {
			VStack {
				StatisticValue(value: $value)
				Text(name.lowercased())
					.font(textTheme.titleMedium.font)
					.bold()
					.lineLimit(1)
			}
			.foregroundStyle(Assets.Colors.bodyColor)
		}
		.fadeEffect()
	}
}

public struct StatisticValue: View {
	@Binding var value: Int
	@Environment(\.textTheme) var textTheme
	public init(value: Binding<Int>) {
		self._value = value
	}
	private var valueString: String {
		value.compactShort()
	}
	public var body: some View {
		Text(valueString)
			.font(value <= 9999 ? textTheme.titleLarge.font : textTheme.bodyLarge.font)
			.lineLimit(1)
			.contentTransition(.numericText())
	}
}
