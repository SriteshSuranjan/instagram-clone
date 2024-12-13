import Foundation
import SwiftUI
import AppUI

public struct FollowButton: View {
	let isFollowed: Bool
	let isOutlined: Bool
	let follow: () -> Void
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(
		isFollowed: Bool,
		isOutlined: Bool,
		follow: @escaping () -> Void
	) {
		self.isFollowed = isFollowed
		self.isOutlined = isOutlined
		self.follow = follow
	}
	private var title: String {
		isFollowed ? "Following" : "Follow"
	}
	
	public var body: some View {
		if isFollowed {
			EmptyView()
		} else {
			Button {
				follow()
			} label: {
				if isOutlined {
					buttonTitle()
						.background(
							RoundedRectangle(cornerRadius: 6)
								.stroke(Assets.Colors.brightGray, lineWidth: 1)
						)
						.contentShape(.rect)
				} else {
					buttonTitle()
					.background(effectiveColor)
					.clipShape(RoundedRectangle(cornerRadius: 6))
					.contentShape(.rect)
				}
			}
			.scaleEffect()
		}
	}
	
	@ViewBuilder
	private func buttonTitle() -> some View {
		Text(title)
			.font(textTheme.labelLarge.font.bold())
			.foregroundStyle(Assets.Colors.bodyColor)
			.padding(.horizontal, AppSpacing.md)
			.padding(.vertical, AppSpacing.sm)
	}
	
	private var effectiveColor: Color? {
		isOutlined ? nil : Assets.Colors.customReversedAdaptiveColor(
			colorScheme,
			light: Assets.Colors.brightGray,
			dark: Assets.Colors.emphasizeDarkGrey
		)
	}
}

#Preview {
	Group {
		FollowButton(isFollowed: false, isOutlined: false, follow: {})
		FollowButton(isFollowed: false, isOutlined: true, follow: {})
	}
}
