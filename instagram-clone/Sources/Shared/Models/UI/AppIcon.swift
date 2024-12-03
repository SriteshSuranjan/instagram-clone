import SwiftUI
import RswiftResources

public enum AppIcon: Identifiable, Hashable {
	case system(String)
	case asset(RswiftResources.ImageResource)
	
	public var image: Image {
		switch self {
		case .system(let name): return Image(systemName: name)
		case .asset(let resource): return Image(resource)
		}
	}
	public var id: String {
		switch self {
		case .system(let string): return string
		case .asset(let imageResource): return imageResource.name
		}
	}
	public static func ==(lhs: AppIcon, rhs: AppIcon) -> Bool {
		lhs.id == rhs.id
	}
	public func hash(into hasher: inout Hasher) {
		id.hash(into: &hasher)
	}
}
