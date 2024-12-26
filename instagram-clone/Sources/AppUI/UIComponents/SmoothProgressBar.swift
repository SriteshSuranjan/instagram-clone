import Foundation
import SwiftUI

public struct SmoothProgressBar: View {
	let color: Color
	let backgroundColor: Color
	let height: CGFloat
	@Binding var progress: CGFloat
	@GestureState private var isDragging: Bool = false
	@State private var dragProgress: CGFloat = 0
	public init(
		color: Color,
		backgroundColor: Color,
		height: CGFloat = 4,
		progress: Binding<CGFloat>
	) {
		self.color = color
		self.backgroundColor = backgroundColor
		self.height = height
		self._progress = progress
	}

	public var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				Rectangle()
					.fill(backgroundColor)
					.frame(width: geometry.size.width)

				Rectangle()
					.fill(color)
					.frame(width: geometry.size.width * progress)
					.animation(isDragging ? nil : .linear(duration: 0.25), value: progress)

				// 透明的拖动区域
				Rectangle()
					.fill(Color.clear)
					.frame(width: geometry.size.width)
					.contentShape(Rectangle())
					.gesture(
						DragGesture(minimumDistance: 0)
							.updating($isDragging) { _, state, _ in
								state = true
							}
							.onChanged { value in
								let newProgress = max(0, min(1, value.location.x / geometry.size.width))
								dragProgress = newProgress
								progress = newProgress
							}
					)
			}
		}
		.frame(height: height)
	}
}
