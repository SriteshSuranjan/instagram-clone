import Foundation

public struct AppNavigationBarTrailingAction: Identifiable {
	public let icon: AppIcon
	public let action: () -> Void
	public init(icon: AppIcon, action: @escaping () -> Void) {
		self.icon = icon
		self.action = action
	}
	public var id: String {
		switch icon {
		case .system(let string): return string
		case .asset(let imageResource): return imageResource.name
		}
	}
}
