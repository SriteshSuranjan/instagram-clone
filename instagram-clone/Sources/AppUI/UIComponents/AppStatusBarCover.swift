import SwiftUI

public struct AppStatusBarCover: ViewModifier {
	public func body(content: Content) -> some View {
		ZStack {
			content
			GeometryReader { geometryReader in
				Assets.Colors.appBarBackgroundColor
					.frame(height: geometryReader.safeAreaInsets.top)
					.edgesIgnoringSafeArea([.top])
			}
		}
	}
}

public extension View {
	func coverStatusBar() -> some View {
		self.modifier(AppStatusBarCover())
	}
}
