import Foundation
import SwiftUI
import UIKit

public struct AppLoadingIndeterminateView: View {
	@State private var xOffset: CGFloat = -200
	public init() {}
	public var body: some View {
		GeometryReader { geometryReader in
			ZStack(alignment: .leading) {
				RoundedRectangle(cornerRadius: 5)
					.fill(Color.alphaBlend(foreground: .black.opacity(0.15), background: Assets.Colors.brightGray))

				RoundedRectangle(cornerRadius: 5)
					.fill(Color.alphaBlend(foreground: .black.opacity(0.5), background: .gray))
					.frame(width: geometryReader.size.width / 2)
					.offset(x: xOffset)
					.animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: xOffset)
			}
			.onAppear {
				withAnimation {
					xOffset = geometryReader.size.width
				}
			}
		}
		.frame(height: 3)
		
	}
}

public struct AppLoadingIndeterminateModifier: ViewModifier {
	let isLoading: Bool
	public init(isLoading: Bool) {
		self.isLoading = isLoading
		debugPrint("AppLoadingIndeterminateModifier \(isLoading)")
	}
	public func body(content: Content) -> some View {
		content
			.overlay(alignment: .bottom) {
				if isLoading {
					AppLoadingIndeterminateView()
						.transition(.move(edge: .bottom).combined(with: .opacity))
						.frame(maxWidth: .infinity)
						.frame(height: 3)
				}
				
			}
	}
}

extension View {
	public func appLoadintIndeterminate(presented: Bool) -> some View {
		self.modifier(AppLoadingIndeterminateModifier(isLoading: presented))
	}
}

#Preview {
	AppLoadingIndeterminateView()
}
