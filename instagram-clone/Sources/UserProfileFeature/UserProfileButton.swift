import AppUI
import Foundation
import SwiftUI

public struct UserProfileButton<Content: View>: View {
	let label: String?
	let content: (() -> Content)?
	let textStyle: AppTextStyle?
	let padding: EdgeInsets?
	let color: Color?
	let action: () -> Void
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(
		label: String? = nil,
		content: (() -> Content)? = nil,
		textStyle: AppTextStyle? = nil,
		padding: EdgeInsets? = nil,
		color: Color? = nil,
		action: @escaping () -> Void
	) {
		self.label = label
		self.content = content
		self.textStyle = textStyle
		self.padding = padding
		self.color = color
		self.action = action
	}
	public var body: some View {
		Button(action: action) {
			if let content {
				content()
			} else {
				Text(label ?? "")
					.font(textStyle?.font ?? textTheme.bodyLarge.font)
					.fontWeight(.semibold)
					.lineLimit(1)
					.truncationMode(.tail)
			}
		}
		.buttonStyle(
			UserProfileButtonStyle(
				padding: padding,
				color: color
			)
		)
	}
}

public struct UserProfileButtonStyle: ButtonStyle {
	let padding: EdgeInsets
	let color: Color?
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(
		padding: EdgeInsets? = nil,
		color: Color? = nil
	) {
		self.padding = padding ?? EdgeInsets(top: AppSpacing.sm, leading: AppSpacing.md, bottom: AppSpacing.sm, trailing: AppSpacing.md)
		self.color = color
	}

	private var effectiveBackgroundColor: Color {
		color ?? Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.brightGray, dark: Assets.Colors.emphasizeDarkGrey)
	}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(padding)
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			.background(
				effectiveBackgroundColor.opacity(configuration.isPressed ? 0.5 : 1)
			)
			.clipShape(RoundedRectangle(cornerRadius: 6))
	}
}
