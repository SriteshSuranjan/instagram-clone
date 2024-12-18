import Foundation
import SwiftUI
import Lottie
import AppUI

public struct DividerBlock: View {
	@Environment(\.textTheme) var textTheme
	public init() {}
	public var body: some View {
		VStack {
			AnimatedShimmerDivider()
			InstaLottieAnimationView(animationFile: Assets.Animations.checkedAnimation)
			AnimatedShimmerDivider()
		}
		.overlay(alignment: .bottom) {
			VStack(spacing: AppSpacing.sm) {
				Text("You'are all caught up")
					.font(textTheme.titleLarge.font)
					.bold()
					.foregroundStyle(Assets.Colors.bodyColor)
				Text("You've seen all new posts from the past 3 days.")
					.lineLimit(2)
					.font(textTheme.bodyLarge.font)
					.foregroundStyle(Assets.Colors.gray)
			}
			.padding()
		}
	}
}

#Preview {
	DividerBlock()
}
