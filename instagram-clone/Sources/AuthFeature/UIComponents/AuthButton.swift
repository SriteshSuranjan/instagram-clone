import AppUI
import SwiftUI

public struct AuthButton: View {
	let isLoading: Bool
	let text: String
	let outlined: Bool
	let style: AppButtonStyle
	let action: () -> Void
	@Environment(\.colorScheme) var colorScheme

	public init(
		isLoading: Bool,
		text: String,
		outlined: Bool = true,
		style: AppButtonStyle = AppButtonStyle(foregroundColor: Assets.Colors.bodyColor, fullWidth: true),
		action: @escaping () -> Void
	) {
		self.isLoading = isLoading
		self.text = text
		self.outlined = outlined
		self.style = style
		self.action = action
	}

	public var body: some View {
		ZStack {
			if isLoading {
				SimpleAppButton.inProgress(
					style: AppButtonStyle(
						foregroundColor: .white,
						backgroundColor: Assets.Colors.customReversedAdaptiveColor(
							colorScheme,
							light: Assets.Colors.gray,
							dark: Assets.Colors.darkGray
						),
						fullWidth: true
					)
				)
				.opacity(isLoading ? 1 : 0)
			} else {
				SimpleAppButton.auth(
					text,
					action: action,
					outlined: outlined,
					style: style
				)
				.opacity(isLoading ? 0 : 1)
			}
		}
	}
}
