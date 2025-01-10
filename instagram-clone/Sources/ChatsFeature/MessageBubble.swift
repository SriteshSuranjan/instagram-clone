import AppUI
import Foundation
import Shared
import SwiftUI

public struct MessageBubble: View {
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public let message: Message
	public let isMine: Bool
	public let corner: RectangleCornerRadii
	@State private var bubbleWidth: CGFloat = 0
	@State private var offset: CGFloat = 0
	public init(isMine: Bool, message: Message, corner: RectangleCornerRadii) {
		self.isMine = isMine
		self.message = message
		self.corner = corner
	}

	public var body: some View {
		messageContent()
			.background(
				bubbleBackground()
					.clipShape(UnevenRoundedRectangle(cornerRadii: corner))
			)
			.background(
				GeometryReader {
					Color.clear.preference(
						key: ViewOffsetKey.self,
						value: $0.frame(in: .global).minY
					)
				}
			)
			.onPreferenceChange(ViewOffsetKey.self) {
				offset = $0
				debugPrint("bubbleOffset: \(offset)")
			}
			.frame(maxWidth: bubbleWidth, alignment: isMine ? .trailing : .leading)
			.frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
			.onGeometryChange(for: CGFloat.self) { proxy in
				let frame = proxy.frame(in: .scrollView)
				return frame.width * 0.7
			} action: { newValue in
				bubbleWidth = newValue
			}
	}
	
	@ViewBuilder
	private func bubbleBackground() -> some View {
		if !isMine {
			Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.white, dark: Assets.Colors.primaryDarkBlue)
		} else {
			GeometryReader {
				GradientBackgroundView(
					offset: offset,
					height: $0.size.height
				)
			}
		}
	}

	@ViewBuilder
	private func messageContent() -> some View {
		BubbleLayout(maxBubbleWidth: max(bubbleWidth - 2 * AppSpacing.md, 0)) {
			Text(message.message)
				.lineLimit(nil)
				.multilineTextAlignment(.leading)
				.font(textTheme.bodyLarge.font)
				.fontWeight(.semibold)
				
			Text(message.createdAt, style: .time)
				.lineLimit(1)
				.font(textTheme.bodySmall.font)
		}
		.foregroundStyle(!isMine ? Assets.Colors.bodyColor : Assets.Colors.white)
		.padding(.bottom, AppSpacing.xs + AppSpacing.xs / 2)
		.padding(.top, AppSpacing.md)
		.padding(.horizontal, AppSpacing.md)
	}
	
	private func GradientBackgroundView(offset: CGFloat, height: CGFloat) -> some View {
		let screenBounds = UIScreen.main.bounds
		let startY = offset / height
		let endY = 1 + (screenBounds.height - offset - height) / height
		return LinearGradient(
			colors: Assets.Colors.primaryMessageBubbleGradient,
			startPoint: .init(x: 0, y: -startY),
			endPoint: .init(x: 0, y: endY)
		)
		.frame(width: screenBounds.width, height: screenBounds.height)
	}
}

/// 自定义布局：
/// 内容视图[文本] + 附加视图[时间戳] 同时放入
/// 根据文本实际宽度决定时间戳的位置
struct BubbleLayout: Layout {
	// 如果想限制气泡最大宽度，可以在这里传参
	var maxBubbleWidth: CGFloat
		
	struct CacheData {
		// 这里可以缓存测量结果
	}
		
	func makeCache(subviews: Subviews) -> CacheData {
		CacheData()
	}
		
	func sizeThatFits(proposal: ProposedViewSize,
	                  subviews: Subviews,
	                  cache: inout CacheData) -> CGSize
	{
		// 先假设 subviews[0] 是文本, subviews[1] 是时间戳
		guard subviews.count == 2 else {
			return .zero
		}
				
		let textView = subviews[0]
		let timeView = subviews[1]
				
		// 1) 测量文本理想大小。最多不超过 maxBubbleWidth
		let textSize = textView.sizeThatFits(
			ProposedViewSize(width: maxBubbleWidth, height: nil)
		)
				
		let timeSize = timeView.sizeThatFits(.unspecified)
		// 2) 决定气泡最终宽度 = textSize.width (可再加 padding),
		//   但不超过 maxBubbleWidth
		let bubbleWidth = min(textSize.width + timeSize.width, maxBubbleWidth)
				
		// 3) 时间戳理想大小:
		//   你可用 ProposeViewSize(width: nil, height: nil)
		//   也可固定
				
		// 4) 气泡高度 = 文本高度 & 行高 & 内边距 => 这里按自己需求算
		//   如果你想让时间戳跟文本底部对齐，高度就是 max(textSize.height, timeSize.height) + 内边距
		let totalHeight = textSize.height + timeSize.height
				
		// 5) 额外可加一些气泡上下左右的 padding
		//   这里简单加个 10
		let finalWidth = bubbleWidth
		let finalHeight = totalHeight
				
		return CGSize(width: finalWidth, height: finalHeight)
	}
		
	func placeSubviews(in bounds: CGRect,
	                   proposal: ProposedViewSize,
	                   subviews: Subviews,
	                   cache: inout CacheData)
	{
		guard subviews.count == 2 else { return }
		let textView = subviews[0]
		let timeView = subviews[1]
			
		// 这里再测量一次以获取实际大小
		let textSize = textView.sizeThatFits(
			ProposedViewSize(width: maxBubbleWidth, height: nil)
		)
		let bubbleWidth = min(textSize.width, maxBubbleWidth)
				
		let timeSize = timeView.sizeThatFits(.unspecified)
				
		// 气泡的 content 区域，去掉 20 的 padding (按上面 sizeThatFits 的计算)
		let contentFrame = bounds.insetBy(dx: /* AppSpacing.sm */ 0, dy: /* AppSpacing.xs */ 0)
				
		// 文本放在左上角
		let textX = contentFrame.minX
		let textY = contentFrame.minY
				
		// 让文本框宽度 = bubbleWidth
		// 高度 = textSize.height
		textView.place(
			at: CGPoint(x: textX, y: textY),
			proposal: ProposedViewSize(width: bubbleWidth, height: textSize.height)
		)
				
		// 决定时间戳的 x 位置:
		// 如果 textSize.width < maxBubbleWidth，说明还没撑满气泡，
		// 所以让时间戳贴着文本末尾 textX + textSize.width
		// 否则贴着气泡右侧 contentFrame.maxX
		let timestampX: CGFloat
		if textSize.width + timeSize.width < maxBubbleWidth {
			timestampX = textX + textSize.width
		} else {
			timestampX = contentFrame.maxX - timeSize.width
		}
				
		// Y位置一般贴着文本的底部(或稍微留点空间)
		let timestampY = contentFrame.maxY - timeSize.height
				
		timeView.place(
			at: CGPoint(x: timestampX, y: timestampY),
			proposal: ProposedViewSize(width: timeSize.width, height: timeSize.height)
		)
	}
}

struct ViewOffsetKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
