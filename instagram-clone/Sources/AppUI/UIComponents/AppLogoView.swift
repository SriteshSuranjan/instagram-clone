import SwiftUI

public struct AppLogoView: View {
	let width: CGFloat?
	let height: CGFloat?
	let color: Color?
	let contentMode: ContentMode
	public init(width: CGFloat?, height: CGFloat?, color: Color?, contentMode: ContentMode) {
		self.width = width
		self.height = height
		self.color = color
		self.contentMode = contentMode
	}
	public var body: some View {
		Assets.Images.logo
			.view(
				width: width ?? 50,
				height: height ?? 50,
				contentMode: contentMode,
				tint: color
			)
	}
}

#Preview {
	AppLogoView(
		width: .infinity,
		height: nil,
		color: Assets.Colors.blue,
		contentMode: .fit
	)
}
