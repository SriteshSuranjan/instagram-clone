import AppUI
import Foundation
import Kingfisher
import SwiftUI

public struct UserProfileAvatar: View {
	let userId: String?
	let avatarUrl: String?
	let radius: CGFloat?
	let strokeWidth: CGFloat?
	let resizeWidth: CGFloat?
	let resizeHeight: CGFloat?
	let isLarge: Bool
	let onTapPickImage: Bool
	let withSimmerPlacehoolder: Bool
	let animationConfig: ButtonAnimationConfig
	let withAddButton: Bool
	let enableBorder: Bool
	let enableInactiveBorder: Bool
	let showStories: Bool
	let withAdaptiveBorder: Bool
	let onTap: ((String?) -> Void)?
	let onLongPress: ((String?) -> Void)?
	let onAddButtonTap: (() -> Void)?
	let onImagePick: (() -> Void)?
	public init(
		userId: String?,
		avatarUrl: String?,
		radius: CGFloat? = nil,
		strokeWidth: CGFloat? = nil,
		resizeWidth: CGFloat? = nil,
		resizeHeight: CGFloat? = nil,
		isLarge: Bool = true,
		onTapPickImage: Bool = false,
		withSimmerPlacehoolder: Bool = false,
		animationConfig: ButtonAnimationConfig = .init(scale: ScaleStrength.xxs, opacity: 1.0, duration: 0.2, hapticFeedback: .none),
		withAddButton: Bool = false,
		enableBorder: Bool = true,
		enableInactiveBorder: Bool = false,
		showStories: Bool = false,
		withAdaptiveBorder: Bool = false,
		onTap: ((String?) -> Void)? = nil,
		onLongPress: ((String?) -> Void)? = nil,
		onAddButtonTap: (() -> Void)? = nil,
		onImagePick: (() -> Void)? = nil
	) {
		self.userId = userId
		self.avatarUrl = avatarUrl
		self.radius = radius
		self.strokeWidth = strokeWidth
		self.resizeWidth = resizeWidth
		self.resizeHeight = resizeHeight
		self.isLarge = isLarge
		self.onTapPickImage = onTapPickImage
		self.withSimmerPlacehoolder = withSimmerPlacehoolder
		self.animationConfig = animationConfig
		self.withAddButton = withAddButton
		self.enableBorder = enableBorder
		self.enableInactiveBorder = enableInactiveBorder
		self.showStories = showStories
		self.withAdaptiveBorder = withAdaptiveBorder
		self.onTap = onTap
		self.onLongPress = onLongPress
		self.onAddButtonTap = onAddButtonTap
		self.onImagePick = onImagePick
	}

	@Environment(\.colorScheme) var colorScheme
	private var effectiveRadius: CGFloat {
		radius ?? (isLarge ? 42 : (withAdaptiveBorder ? 22 : 18))
	}

	private var width: CGFloat {
		effectiveRadius * 2
	}

	private var height: CGFloat {
		effectiveRadius * 2
	}

	public var body: some View {
		Button {
			if let onTap {
				onTap(userId)
			}
		} label: {
			if let avatarUrl {
				KFImage.url(URL(string: avatarUrl))
					.placeholder {
						Assets.Images.profilePhoto
							.view(width: width, height: height)
							.clipShape(.circle)
					}
					.resizable()
					.fade(duration: 0.2)
					.frame(width: width, height: height)
					.clipShape(.circle)
					.padding(AppSpacing.xs)
					.overlay {
						if !withAdaptiveBorder {
							gradient()
						} else {
							Circle()
								.stroke(Assets.Colors.bodyColor, lineWidth: 3, antialiased: true)
						}
					}
			} else {
				Assets.Images.profilePhoto
					.view(width: width, height: height)
					.padding(AppSpacing.xs)
					.clipShape(Circle())
					.overlay {
						if !withAdaptiveBorder {
							gradient()
						} else {
							Circle()
								.stroke(Assets.Colors.bodyColor, lineWidth: 3, antialiased: true)
						}
					}
			}
		}
		.scaleEffect(config: animationConfig)
		.onLongPressGesture {
			if let onLongPress {
				onLongPress(userId)
			}
		}
		
	}
	
	private static let defaultGradient = AngularGradient(
		colors: Assets.Colors.primaryGradient,
		center: .center,
		startAngle: .degrees(0),
		endAngle: .degrees(360)
	)
			
	private static let gradientBorderDecoration = AnyView(
		Circle()
			.stroke(defaultGradient, lineWidth: 2)
	)
			
	private static let blackBorderDecoration = AnyView(
		Circle()
			.stroke(Color.black, lineWidth: 3)
	)
			
	private static let whiteBorderDecoration = AnyView(
		Circle()
			.stroke(Color.white, lineWidth: 3)
	)
			
	private func greyBorderDecoration(isDark: Bool) -> some View {
		let color = isDark ? Color.gray.opacity(0.8) : Color.gray.opacity(0.4)
		return Circle()
			.stroke(color, lineWidth: 1)
	}
			
	@ViewBuilder
	private func border(isDark: Bool) -> some View {
		if !enableInactiveBorder && !showStories {
			EmptyView()
		} else if showStories {
			UserProfileAvatar.gradientBorderDecoration
		} else if enableInactiveBorder && !showStories {
			greyBorderDecoration(isDark: isDark)
		}
	}
			
	@ViewBuilder
	private func gradient() -> some View {
		if !enableInactiveBorder && !showStories {
			Circle()
				.fill(Color.clear)
		} else if showStories {
			Circle()
				.stroke(UserProfileAvatar.defaultGradient, lineWidth: strokeWidth ?? 2)
		} else if enableInactiveBorder && !showStories {
			Circle()
				.stroke(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.6)]), startPoint: .leading, endPoint: .trailing), lineWidth: strokeWidth ?? 2)
			
		}
	}
}

#Preview {
	Group {
		UserProfileAvatar(userId: nil, avatarUrl: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/sign/avatars/2024-12-08T16:33:25.311523.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJhdmF0YXJzLzIwMjQtMTItMDhUMTY6MzM6MjUuMzExNTIzLmpwZyIsImlhdCI6MTczMzY0NjgwNywiZXhwIjoyMDQ5MDA2ODA3fQ.mYzEDqENZmbwTlRGdoMDrPrvPiIWJ5Yefe4mlwAXHcM", radius: 42, strokeWidth: 2, showStories: true)
		UserProfileAvatar(userId: nil, avatarUrl: nil, radius: 42, strokeWidth: 2, showStories: false, withAdaptiveBorder: true)
		UserProfileAvatar(userId: nil, avatarUrl: nil, radius: 42, strokeWidth: 2, enableInactiveBorder: true, showStories: false, withAdaptiveBorder: false)
	}
	.frame(width: 200, height: 200)
}
