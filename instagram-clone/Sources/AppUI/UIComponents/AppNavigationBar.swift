import SwiftUI
import Shared

public struct AppNavigationBar: View {
	let title: String
	let backButtonAction: (() -> Void)?
	let actions: [AppNavigationBarTrailingAction]
	@Environment(\.textTheme) var textTheme
	public init(
		title: String,
		backButtonAction: (() -> Void)?,
		actions: [AppNavigationBarTrailingAction] = []
	) {
		self.title = title
		self.backButtonAction = backButtonAction
		self.actions = actions
	}
	public var body: some View {
		HStack(spacing: AppSpacing.xlg) {
			if let backButtonAction {
				Button {
					backButtonAction()
				} label: {
					Image(systemName: "chevron.backward")
						
				}
			}
			Text(title)
			Spacer()
			ForEach(actions.reversed()) { action in
				Button {
					action.action()
				} label: {
					action.icon.image
						.resizable()
						.frame(
							width: AppSize.iconSize,
							height: AppSize.iconSize
						)
				}
				.fadeEffect()
			}
		}
		.font(textTheme.headlineMedium.font)
		.foregroundStyle(Assets.Colors.bodyColor)
	}
}
