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
		
	}
}

#Preview {
	AppLoadingIndeterminateView()
}
