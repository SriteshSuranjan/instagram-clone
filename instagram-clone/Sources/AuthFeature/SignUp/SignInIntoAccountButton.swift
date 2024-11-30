import SwiftUI
import AppUI

public struct SignInIntoAccountButton: View {
	@Environment(\.textTheme) var textTheme
	let action: () -> Void
	public init(action: @escaping () -> Void) {
		self.action = action
	}
	public var body: some View {
		Button(action: action) {
			Text("Alreay have an account? ")
				.font(textTheme.bodyMedium.font)
				.foregroundStyle(Assets.Colors.bodyColor)
			+
			Text("Sign In")
				.font(textTheme.bodyMedium.font)
				.foregroundStyle(Assets.Colors.blue)
		}
	}
}

