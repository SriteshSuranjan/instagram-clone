import SwiftUI
import RswiftResources

public enum AppIcon {
	case system(String)
	case asset(RswiftResources.ImageResource)
	
	public var image: Image {
		switch self {
		case .system(let name): return Image(systemName: name)
		case .asset(let resource): return Image(resource)
		}
	}
}
