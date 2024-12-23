import SwiftUI

private struct ScrollOffsetPreferenceKey: PreferenceKey {
	static var defaultValue: CGPoint = .zero
		
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

public struct BlurScroll: ViewModifier {
	public enum BlurPosition {
		case top
		case bottom
	}
		
	let blur: CGFloat
	let blurHeight: CGFloat
	let blurPosition: BlurPosition
	let enableScroll: Bool
		
	let coordinateSpaceName = "scroll"
		
	@State private var scrollPosition: CGPoint = .zero
		
	public func body(content: Content) -> some View {
		let gradient = LinearGradient(stops: [
			.init(color: .white, location: 0.10),
			.init(color: .clear, location: blurHeight),
		],
		startPoint: .bottom,
		endPoint: .top)
				
		let invertedGradient = LinearGradient(stops: [
			.init(color: .clear, location: 0.10),
			.init(color: .white, location: blurHeight),
		],
		startPoint: .bottom,
		endPoint: .top)
				
		GeometryReader { topGeo in
			if enableScroll {
				scrollContent(content, topGeo: topGeo, gradient: gradient, invertedGradient: invertedGradient)
			} else {
				staticContent(content, topGeo: topGeo, gradient: gradient, invertedGradient: invertedGradient)
			}
		}
	}
		
	@ViewBuilder
	private func scrollContent(_ content: Content, topGeo: GeometryProxy, gradient: LinearGradient, invertedGradient: LinearGradient) -> some View {
		ScrollView {
			ZStack(alignment: .top) {
				content
					.mask(
						VStack(spacing: 0) {
							(blurPosition == .bottom ? invertedGradient : gradient)
								.frame(height: topGeo.size.height, alignment: .top)
								.offset(y: -scrollPosition.y)
							Spacer(minLength: 0)
						}
					)
								
				content
					.blur(radius: blur)
					.frame(height: topGeo.size.height, alignment: .top)
					.mask(
						(blurPosition == .bottom ? gradient : invertedGradient)
							.frame(height: topGeo.size.height)
							.offset(y: -scrollPosition.y)
					)
			}
			.frame(maxHeight: .infinity)
			.background(GeometryReader { geo in
				Color.clear
					.preference(key: ScrollOffsetPreferenceKey.self,
					            value: geo.frame(in: .named(coordinateSpaceName)).origin)
			})
			.onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
				self.scrollPosition = value
			}
		}
		.coordinateSpace(name: coordinateSpaceName)
	}
		
	@ViewBuilder
	private func staticContent(_ content: Content, topGeo: GeometryProxy, gradient: LinearGradient, invertedGradient: LinearGradient) -> some View {
		ZStack(alignment: .top) {
			content
				.mask(
					VStack(spacing: 0) {
						(blurPosition == .bottom ? invertedGradient : gradient)
							.frame(height: topGeo.size.height)
						Spacer(minLength: 0)
					}
				)
						
			content
				.blur(radius: blur)
				.frame(height: topGeo.size.height)
				.mask(
					(blurPosition == .bottom ? gradient : invertedGradient)
						.frame(height: topGeo.size.height)
				)
		}
		.frame(maxHeight: .infinity)
	}
}

public extension View {
	func blurScroll(_ blur: CGFloat,
	                blurHeight: CGFloat = 0.25,
	                blurPosition: BlurScroll.BlurPosition = .bottom,
	                enableScroll: Bool = true) -> some View
	{
		modifier(BlurScroll(
			blur: blur,
			blurHeight: blurPosition == .bottom ? blurHeight : 1 - blurHeight,
			blurPosition: blurPosition,
			enableScroll: enableScroll
		))
	}
}
