import AppUI
import SwiftUI

public struct SignInButton: View {
	@Environment(\.colorScheme) var colorScheme
	let isLoading: Bool
	let action: () -> Void
	public init(isLoading: Bool, action: @escaping () -> Void) {
		self.isLoading = isLoading
		self.action = action
	}

	public var body: some View {
		ZStack {
			if isLoading {
				SimpleAppButton.inProgress(
					style: AppButtonStyle(foregroundColor: .white, backgroundColor: Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.gray, dark: Assets.Colors.darkGray), fullWidth: true)
				)
					.opacity(isLoading ? 1 : 0)
			} else {
				SimpleAppButton.auth(
					"Sign In",
					action: action,
					style: AppButtonStyle(foregroundColor: Assets.Colors.bodyColor, fullWidth: true)
				)
				.opacity(isLoading ? 0 : 1)
			}
		}
		.padding(.horizontal, AppSpacing.xlg)
	}
}
