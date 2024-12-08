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
		case .medium: return 46
		case .large: return 64
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
		if let avatarUrl = URL(string: url ?? "") {
			KFImage.url(avatarUrl)
				.resizable()
				.fade(duration: 0.25)
				.frame(width: size.radius, height: size.radius)
				.scaledToFit()
				.clipShape(Circle())
		} else {
			AvatarPlaceholderView(
				title: title,
				size: size.radius,
				font: titleFont
			)
		}
	}
	var titleFont: Font {
		switch size {
		case .small: return textTheme.bodyLarge.font
		case .medium: return textTheme.titleLarge.font
		case .large: return textTheme.headlineLarge.font
		}
	}
}

public struct AvatarPlaceholderView: View {
	let title: PersonNameComponents
	let size: CGFloat
	let font: Font
	@Environment(\.textTheme) var textTheme
	public init(title: PersonNameComponents, size: CGFloat, font: Font) {
		self.title = title
		self.size = size
		self.font = font
	}

	private var determinedColor: Color {
		let firstLetter = title.formatted(.name(style: .abbreviated))
			.prefix(1)

		// 找到对应的颜色数组
		let colors = letterColors.first { range, _ in
			range.contains(String(firstLetter))
		}?.value ?? letterColors.first!.value

		// 使用名字的 hash 值来确定使用哪个颜色
		let index = abs(title.formatted(.name(style: .abbreviated)).hashValue) % colors.count
		return colors[index]
	}

	public var body: some View {
		determinedColor
			.frame(width: size, height: size)
			.overlay {
				Text(title, format: .name(style: .abbreviated))
					.font(font.bold())
					.foregroundStyle(.white)
			}
			.clipShape(Circle())
	}
}
