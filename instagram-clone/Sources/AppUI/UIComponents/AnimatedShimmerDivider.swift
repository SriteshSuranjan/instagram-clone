import Foundation
import SwiftUI


public struct AnimatedShimmerDivider: View {
	let shimmerBaseColor: Color?
	let shimmerGradient: [Color]
	@Environment(\.colorScheme) var colorScheme
	@State private var isAnimating = false
	@State private var showShimmer = true
	public init(
		shimmerBaseColor: Color? = nil,
		shimmerGradient: [Color] = Assets.Colors.primaryGradient
	) {
		self.shimmerBaseColor = shimmerBaseColor
		self.shimmerGradient = shimmerGradient
	}
	public var body: some View {
		Rectangle()
			.fill(
				shimmerBaseColor ?? Assets.Colors.customReversedAdaptiveColor(
					colorScheme,
					light: Assets.Colors.gray,
					dark: Assets.Colors.emphasizeDarkGrey
				)
			)
			.overlay {
				GeometryReader { geometryReader in
					Rectangle()
						.fill(
							LinearGradient(
								colors: shimmerGradient,
								startPoint: .leading,
								endPoint: .trailing
							)
						)
						.blur(radius: 0.6)
						.offset(x: isAnimating ? geometryReader.size.width : 0)
				}
				.opacity(showShimmer ? 1 : 0)
				.animation(.easeInOut, value: showShimmer)
			}
			.frame(maxWidth: .infinity)
			.frame(height: 1)
			.onAppear {
				withAnimation(.easeInOut(duration: 2).delay(0.3)) {
					isAnimating = true
				} completion: {
					showShimmer = false
				}
			}
	}
}
