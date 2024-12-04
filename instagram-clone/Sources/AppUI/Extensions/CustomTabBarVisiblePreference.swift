import SwiftUI

public struct CustomTabBarVisiblePreference: PreferenceKey {
	// nil means "not set"
	public static let defaultValue: Bool? = nil

	public static func reduce(value: inout Bool?, nextValue: () -> Bool?) {
		guard let next = nextValue() else { return }
		value = next
	}
}
