import SwiftUI

public struct BottomBarVisible: Equatable {
	public let tabBarVisible: Bool
	public let loadingBarVisible: Bool
	public init(tabBarVisible: Bool = true, loadingBarVisible: Bool = false) {
		self.tabBarVisible = tabBarVisible
		self.loadingBarVisible = loadingBarVisible
	}
}

public struct BottomBarVisiblePreference: PreferenceKey {
	// nil means "not set"
	public static let defaultValue = BottomBarVisible()

	public static func reduce(value: inout BottomBarVisible, nextValue: () -> BottomBarVisible) {
		value = nextValue()
	}
}
