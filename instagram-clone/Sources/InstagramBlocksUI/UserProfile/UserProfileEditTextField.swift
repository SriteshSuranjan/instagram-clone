import Foundation
import SwiftUI
import AppUI

public struct UserProfileEditTextField: View {
	let title: String
	let focused: Bool
	let text: String
	let onTap: () -> Void
	public init(title: String, focused: Bool, text: String, onTap: @escaping () -> Void) {
		self.title = title
		self.focused = focused
		self.text = text
		self.onTap = onTap
	}
	@Environment(\.textTheme) var textTheme
	public var body: some View {
		VStack(alignment: .leading) {
			if !text.isEmpty {
				Text(title)
					.font(textTheme.titleSmall.font)
					.foregroundStyle(Assets.Colors.gray)
			}
			TextField(title, text: .constant(text))
				.font(textTheme.titleLarge.font)
				.textFieldStyle(.plain)
				.disabled(true)
			Divider()
				.frame(height: focused ? 2 : 0.5)
				.background(Assets.Colors.bodyColor)
		}
		.contentShape(.rect)
		.onTapGesture {
			onTap()
		}
	}
}

#Preview {
	VStack(spacing: AppSpacing.lg) {
		UserProfileEditTextField(title: "Name", focused: false, text: "控流", onTap: {})
		UserProfileEditTextField(title: "Username", focused: true, text: "kongliu", onTap: {})
		UserProfileEditTextField(title: "Bio", focused: false, text: "", onTap: {})
	}
	.padding(.horizontal)
}
