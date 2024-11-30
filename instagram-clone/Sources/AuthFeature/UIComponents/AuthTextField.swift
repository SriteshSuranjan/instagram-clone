import SwiftUI
import AppUI

public struct AuthTextField<TrailingView: View>: View {
	let placeholder: String
	let errorMessage: String?
	let isSecure: Bool
	let showSensitive: Bool
	@Binding var input: String
	let trailingView: () -> TrailingView
	public init(
		placeholder: String,
		errorMessage: String?,
		isSecure: Bool = false,
		showSensitive: Bool = false,
		input: Binding<String>,
		@ViewBuilder trailingView: @escaping () -> TrailingView = { EmptyView() }
	) {
		self.placeholder = placeholder
		self.errorMessage = errorMessage
		self.isSecure = isSecure
		self.showSensitive = showSensitive
		self._input = input
		self.trailingView = trailingView
	}
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			displayTextField()
				.appTextField(
					font: textTheme.bodyLarge.font,
					foregroundColor: Assets.Colors.bodyColor,
					accentColor: Assets.Colors.bodyColor,
					backgroundColor: Assets.Colors.customReversedAdaptiveColor(
						colorScheme,
						light: Assets.Colors.brightGray,
						dark: Assets.Colors.dark
					),
					keyboardType: .emailAddress,
					returnKeyType: .next,
					trailingView: trailingView
				)
			if let errorMessage {
				HStack {
					Text(errorMessage)
						.font(textTheme.bodyLarge.font)
						.foregroundStyle(Assets.Colors.red)
						.transition(.move(edge: .top))
					Spacer()
				}
			}
		}
//		.padding(.top, AppSpacing.md)
	}
	
	@ViewBuilder
	private func displayTextField() -> some View {
		ZStack {
			if isSecure {
				ZStack {
					SecureField(placeholder, text: $input)
						.opacity(showSensitive ? 0 : 1)
					TextField(placeholder, text: $input)
						.opacity(showSensitive ? 1 : 0)
				}
			} else {
				TextField(placeholder, text: $input)
			}

			
		}
	}
}
