import SwiftUI
import AppUI

public struct OrDivider: View {
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.textTheme) var textTheme
	public var body: some View {
		HStack(spacing: AppSpacing.md) {
			AppDivider(
				color: Assets.Colors.bodyColor
			)
			Text("OR")
				.foregroundStyle(Assets.Colors.bodyColor)
				.font(textTheme.titleMedium.font)
			AppDivider(
				color: Assets.Colors.bodyColor
			)
		}
		.padding(.vertical, AppSpacing.xlg)
	}
}
