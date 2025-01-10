import SwiftUI
struct GradientBubbleOverlay: View {
		/// 整个滚动容器（或根容器）的 size，用来定义你的「全屏渐变」高度
	let containerSize: CGSize
		
		/// 要绘制的颜色数组
		let colors: [Color]
		
		var body: some View {
				GeometryReader { bubbleProxy in
						Canvas { context, size in
								// size == bubbleProxy.size
								// ① bubble 的自身大小
								let bubbleSize = size
								
								// ② bubble 在父容器 coordinateSpace 的位置
								let bubbleFrame = bubbleProxy.frame(in: .named("ScrollViewSpace"))
								
								// ③ 在 Canvas 内部，将坐标系平移到 bubbleFrame 的左上角
								//    这样后续绘制 (0,0) 就对应 bubble 本身的左上角
								context.translateBy(x: -bubbleFrame.minX, y: -bubbleFrame.minY)
								
								// ④ 建立一个 SwiftUI 的 Gradient
								//    若需要自定义 stops，可用 Gradient(stops: [...])
								let gradient = Gradient(colors: colors)
								
								// ⑤ 用 containerSize 来定义渐变的起点和终点
								//    这里示例：从「屏幕上方中点」到「屏幕下方中点」垂直渐变
								let startPoint = CGPoint(x: containerSize.width / 2, y: 0)
							let endPoint   = CGPoint(x: containerSize.width / 2, y: containerSize.height)
								
								// ⑥ 用本地的 (0,0,width,height) 画路径
								let bubbleRect = CGRect(origin: .zero, size: bubbleSize)
								
								// ⑦ 用 .fill + .linearGradient 绘制
								context.fill(
									Path(bubbleRect),
										with: .linearGradient(
												gradient,
												startPoint: startPoint,
												endPoint: endPoint
										)
								)
						}
				}
		}
}
