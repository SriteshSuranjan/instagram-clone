import Foundation
import SwiftUI
import ComposableArchitecture

public struct DotIndicator: View {
	let totalCount: Int
	@Binding var currentIndex: Int
	public init(totalCount: Int, currentIndex: Binding<Int>) {
		self.totalCount = totalCount
		self._currentIndex = currentIndex
	}
	public var body: some View {
		HStack {
			ForEach(0..<totalCount, id: \.self) { index in
				Circle()
					.fill(index == currentIndex ? Assets.Colors.deepBlue.opacity(0.8) : Assets.Colors.gray)
					.frame(
						width: index == currentIndex ? 7.5 : 6,
						height: index == currentIndex ? 7.5 : 6
					)
					.transition(.opacity)
			}
		}
		.padding(.horizontal, AppSpacing.xxs)
	}
}
