import SwiftUI

public struct AppDivider: View {
	let height: CGFloat?
	let indent: CGFloat?
	let endIndent: CGFloat?
	let color: Color?
	@Environment(\.colorScheme) var colorScheme
	public init(height: CGFloat? = nil, indent: CGFloat? = nil, endIndent: CGFloat? = nil, color: Color? = nil) {
		self.height = height
		self.indent = indent
		self.endIndent = endIndent
		self.color = color
	}
	var effectiveColor: Color {
		Assets.Colors.customReversedAdaptiveColor(
			colorScheme,
			light: AppColors.brightGrey,
			dark: AppColors.emphasizeDarkGrey
		)
	}
	public var body: some View {
		Rectangle()
			.fill(color ?? effectiveColor)
			.frame(maxWidth: .infinity)
			.frame(height: height ?? 1.0)
			.padding(.leading, indent ?? 0)
			.padding(.trailing, endIndent ?? 0)
	}
}
