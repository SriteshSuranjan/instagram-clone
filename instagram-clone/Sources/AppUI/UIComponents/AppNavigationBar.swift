import SwiftUI

public struct AppNavigationBar: View {
	let title: String
	let backButtonAction: () -> Void
	@Environment(\.textTheme) var textTheme
	public init(title: String, backButtonAction: @escaping () -> Void) {
		self.title = title
		self.backButtonAction = backButtonAction
	}
	public var body: some View {
		HStack(spacing: AppSpacing.xlg) {
			Button {
				backButtonAction()
			} label: {
				Image(systemName: "chevron.backward")
			}
			Text(title)
			Spacer()
		}
		.font(textTheme.headlineMedium.font)
		.foregroundStyle(Assets.Colors.bodyColor)
	}
}
