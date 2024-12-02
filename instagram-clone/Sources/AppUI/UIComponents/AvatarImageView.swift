import Foundation
import Kingfisher
import Shared
import SwiftUI

public enum AvatarImageSize {
	case small
	case medium
	case large
	
	public var radius: CGFloat {
		switch self {
		case .small: return 28
		case .medium: return 36
		case .large: return 42
		}
	}
}

public struct AvatarImageView: View {
	let title: PersonNameComponents
	let size: AvatarImageSize
	let url: String?
	@Environment(\.textTheme) var textTheme
	public init(
		title: PersonNameComponents,
		size: AvatarImageSize,
		url: String?
	) {
		self.title = title
		self.size = size
		self.url = url
	}
	public var body: some View {
		KFImage.url(URL(string: url ?? ""))
			.placeholder {
				Image(systemName: "person.circle.fill")
					.resizable()
			}
			.fade(duration: 0.25)
			.resizable()
			.scaledToFit()
			.clipShape(Circle())
			.frame(width: size.radius, height: size.radius)
//		KFImage.url(URL(string: url ?? ""))
////			.placeholder {
////				Color.random
////					.overlay {
////						Text(title, format: .name(style: .abbreviated))
////							.font(textTheme.titleMedium.font)
////							.foregroundStyle(.white)
////					}
////					.clipShape(Circle())
////			}
//			.clipShape(Circle())
//			.frame(width: size.radius, height: size.radius)
	}
}
