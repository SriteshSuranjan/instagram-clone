import SwiftUI
import AppUI

public struct ForgotPasswordButton: View {
	@Environment(\.textTheme) var textTheme
	let action: () -> Void
	public init(action: @escaping () -> Void) {
		self.action = action
	}
	public var body: some View {
		Button(action: action) {
			Text("Forgot Password?")
				.font(textTheme.titleSmall.font)
				.foregroundStyle(AppColors.blue)
		}
	}
}
