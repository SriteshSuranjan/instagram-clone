import SwiftUI

public enum AppIcon: Equatable {
	case system(String)
	case asset(ImageResource)
	
	public var image: Image {
		switch self {
		case .system(let name): return Image(systemName: name)
		case .asset(let resource): return Image(resource)
		}
	}
}
