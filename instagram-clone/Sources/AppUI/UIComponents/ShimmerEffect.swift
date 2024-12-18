import Foundation
import SwiftUI

struct ShimmerEffect: View {
	@State private var isAnimating = false
	@State private var showGradient = true
	var body: some View {
		Rectangle()
			.fill(.gray.opacity(0.3))
			.overlay(
				GeometryReader { geometryReader in
					Rectangle()
						.fill(
							LinearGradient(
								gradient: Gradient(
									colors: Assets.Colors.primaryGradient
								),
								startPoint: .bottomLeading,
								endPoint: .topTrailing
							)
						)
						.offset(x: isAnimating ? geometryReader.size.width : 0)
				}
					.opacity(showGradient ? 1 : 0)
					.animation(.easeInOut, value: showGradient)
			)
			.onAppear {
				withAnimation(.linear(duration: 4.0)) {
					isAnimating = true
				} completion: {
					showGradient = false
				}
			}
	}
}

#Preview {
	ShimmerEffect()
		.frame(maxWidth: .infinity)
		.frame(height: 2)
}
