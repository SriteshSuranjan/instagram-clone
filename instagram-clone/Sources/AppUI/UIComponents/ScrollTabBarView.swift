import Foundation
import Shared
import SwiftUI

// AnyTabItem 保持不变
public struct AnyTabItem<Tag: Hashable>: View {
	public let content: AnyView
	public let tag: Tag

	public init<Content: View>(_ tabItem: TabItem<Content, Tag>) {
		self.content = AnyView(tabItem.content)
		self.tag = tabItem.tag
	}

	public var body: some View {
		content
	}
}

// 修改 TabBuilder 来自动处理类型擦除
@resultBuilder
public enum TabBuilder {
	public static func buildBlock<C0: View, Tag: Hashable>(_ c0: TabItem<C0, Tag>) -> [AnyTabItem<Tag>] {
		[AnyTabItem(c0)]
	}

	public static func buildBlock<C0: View, C1: View, Tag: Hashable>(_ c0: TabItem<C0, Tag>, _ c1: TabItem<C1, Tag>) -> [AnyTabItem<Tag>] {
		[AnyTabItem(c0), AnyTabItem(c1)]
	}

	public static func buildBlock<C0: View, C1: View, C2: View, Tag: Hashable>(
		_ c0: TabItem<C0, Tag>,
		_ c1: TabItem<C1, Tag>,
		_ c2: TabItem<C2, Tag>
	) -> [AnyTabItem<Tag>] {
		[AnyTabItem(c0), AnyTabItem(c1), AnyTabItem(c2)]
	}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, Tag: Hashable>(
		_ c0: TabItem<C0, Tag>,
		_ c1: TabItem<C1, Tag>,
		_ c2: TabItem<C2, Tag>,
		_ c3: TabItem<C3, Tag>
	) -> [AnyTabItem<Tag>] {
		[AnyTabItem(c0), AnyTabItem(c1), AnyTabItem(c2), AnyTabItem(c3)]
	}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, Tag: Hashable>(
		_ c0: TabItem<C0, Tag>,
		_ c1: TabItem<C1, Tag>,
		_ c2: TabItem<C2, Tag>,
		_ c3: TabItem<C3, Tag>,
		_ c4: TabItem<C4, Tag>
	) -> [AnyTabItem<Tag>] {
		[AnyTabItem(c0), AnyTabItem(c1), AnyTabItem(c2), AnyTabItem(c3), AnyTabItem(c4)]
	}
	
	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, Tag: Hashable>(
		_ c0: TabItem<C0, Tag>,
		_ c1: TabItem<C1, Tag>,
		_ c2: TabItem<C2, Tag>,
		_ c3: TabItem<C3, Tag>,
		_ c4: TabItem<C4, Tag>,
		_ c5: TabItem<C5, Tag>
	) -> [AnyTabItem<Tag>] {
		[AnyTabItem(c0), AnyTabItem(c1), AnyTabItem(c2), AnyTabItem(c3), AnyTabItem(c4), AnyTabItem(c5)]
	}
}

// TabItem 保持简单
public struct TabItem<Content: View, Tag: Hashable>: View {
	public let content: Content
	public let tag: Tag

	public init(_ tag: Tag, @ViewBuilder content: () -> Content) {
		self.content = content()
		self.tag = tag
	}

	public var body: some View {
		content
	}
}

public struct ScrollTabBarView<Tag: Hashable>: View {
	@Binding var selection: Tag
	@Environment(\.textTheme) var textTheme
	private let content: [AnyTabItem<Tag>]
	public init(
		selection: Binding<Tag>,
		@TabBuilder content: () -> [AnyTabItem<Tag>]
	) {
		self._selection = selection
		self.content = content()
	}
	
	private var activeIndex: Int {
		content.map(\.tag).firstIndex(of: selection)!
	}

	public var body: some View {
		GeometryReader { geometryReader in
			HStack(spacing: 0) {
				ForEach(0 ..< content.count, id: \.self) { index in
					let item = content[index]
					Button {
						withAnimation(.snappy) {
							selection = item.tag
						}
					} label: {
						item.content
							.font(textTheme.titleLarge.font)
							.foregroundStyle(Assets.Colors.bodyColor)
							.frame(width: geometryReader.size.width / CGFloat(content.count), height: 50)
							.contentShape(.rect)
					}
					.buttonStyle(.plain)
				}
			}
			.overlay(alignment: .bottom) {
				ZStack(alignment: .leading) {
					Rectangle()
						.fill(Assets.Colors.focusColor)
						.frame(height: 1)
					Rectangle()
						.fill(Assets.Colors.bodyColor)
						.frame(width: geometryReader.size.width / CGFloat(content.count), height: 2)
						.offset(x: CGFloat(activeIndex) * geometryReader.size.width / CGFloat(content.count))
				}
			}
			.frame(maxHeight: .infinity)
			.background(Assets.Colors.appBarBackgroundColor)
		}
	}
}

// #Preview {
//	ScrollTabBarView(tabs: [
//		.init(tabBarModel: .icon(.system("square.grid.2x2.fill"))),
//		.init(tabBarModel: .icon(.system("person.fill")))
//	])
// }

// public struct ScrollTabBarView: View {
//	@Binding var tabs: [TabModel]
//	@State private var activeTab: TabModel.TabBarModel
//	@State private var mainViewScrollState: TabModel.TabBarModel?
//	@State private var tabBarScrollState: TabModel.TabBarModel?
//	@State private var progress: CGFloat = .zero
//	public init(tabs: Binding<[TabModel]>) {
//		self._tabs = tabs
//		activeTab = tabs.wrappedValue.first!.tabBarModel
//	}
//	public var body: some View {
//		VStack(spacing: 0) {
//			customTabBar()
//			mockContent()
//		}
//	}
//
//	@ViewBuilder
//	private func customTabBar() -> some View {
//		GeometryReader { geometryReader in
//			ScrollView(.horizontal) {
//				HStack(spacing: 20) {
//					ForEach($tabs) { $tab in
//						Button {
//							withAnimation(.snappy) {
//								activeTab = tab.tabBarModel
//								tabBarScrollState = tab.tabBarModel
//								mainViewScrollState = tab.tabBarModel
//							}
//						} label: {
//							Group {
//								switch tab.tabBarModel {
//								case let .icon(icon):
//									icon.image
//								case let .text(text):
//									Text(text)
//								}
//							}
//								.frame(width: (geometryReader.size.width - 60) / 2)
//								.padding(.vertical, 12)
//								.foregroundStyle(activeTab == tab.tabBarModel ? Assets.Colors.bodyColor : .gray)
//								.contentShape(.rect)
//
//						}
//						.id(tab.tabBarModel)
//						.buttonStyle(.plain)
//						.rect { rect in
//							tab.size = rect.size
//							tab.minX = rect.minX
//						}
//					}
//				}
//				.scrollTargetLayout()
//			}
//
//			.scrollPosition(
//				id: Binding(
//					get: { tabBarScrollState },
//					set: { _ in
//					}
//				),
//				anchor: .center
//			)
//			.overlay(alignment: .bottom) {
//				ZStack(alignment: .leading) {
//					Color.clear
//						.frame(height: 1)
//					let inputRange = tabs.indices.compactMap { CGFloat($0) }
//					let outputRange = tabs.compactMap { $0.size.width }
//					let outputPositionRange = tabs.compactMap { $0.minX }
//					let indicatorWidth = progress.interolate(inputRange: inputRange, outputRange: outputRange)
//					let indicatorPosition = progress.interolate(inputRange: inputRange, outputRange: outputPositionRange)
//					Rectangle()
//						.fill(.primary)
//						.frame(width: indicatorWidth, height: 1.5)
//						.offset(x: indicatorPosition)
//				}
//			}
//			.safeAreaPadding(.horizontal, 15)
//			.scrollIndicators(.hidden)
//		}
//	}
//
//	@ViewBuilder
//	private func mockContent() -> some View {
//		GeometryReader { geometryReader in
//			let size = geometryReader.size
//			ScrollView(.horizontal) {
//				LazyHStack(spacing: 0) {
//					ForEach(tabs) { tab in
//						Group {
//							switch tab.tabBarModel {
//							case let .icon(icon):
//								icon.image
//							case let .text(text):
//								Text(text)
//							}
//						}
//						.id(tab.tabBarModel)
//						.frame(width: size.width, height: size.height)
//						.contentShape(Rectangle())
//					}
//				}
//				.scrollTargetLayout()
//				.rect { rect in
//					progress = -rect.minX / size.width
//				}
//			}
//			.scrollPosition(id: $mainViewScrollState)
//			.scrollIndicators(.hidden)
//			.scrollTargetBehavior(.paging)
//			.onChange(of: mainViewScrollState) { oldValue, newValue in
//				if let newValue {
//					withAnimation(.snappy) {
//						tabBarScrollState = newValue
//						activeTab = newValue
//					}
//				}
//			}
//		}
//	}
// }
//
// public struct RectKey: PreferenceKey {
//	public static var defaultValue: CGRect = .zero
//	public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
//		value = nextValue()
//	}
// }
//
// extension View {
//	@ViewBuilder
//	func rect(completion: @escaping (CGRect) -> ()) -> some View {
//		self
//			.overlay {
//				GeometryReader {
//					let rect = $0.frame(in: .scrollView(axis: .horizontal))
//					Color.clear
//						.preference(key: RectKey.self, value: rect)
//						.onPreferenceChange(RectKey.self, perform: completion)
//				}
//			}
//	}
// }
//
// extension CGFloat {
//	public func interolate(inputRange: [CGFloat], outputRange: [CGFloat]) -> CGFloat {
//		let x = self
//		let length = inputRange.count - 1
//		if x <= inputRange[0] {
//			return outputRange[0]
//		}
//		for index in 1...length {
//			let x1 = inputRange[index - 1]
//			let x2 = inputRange[index]
//
//			let y1 = outputRange[index - 1]
//			let y2 = outputRange[index]
//			if x <= inputRange[index] {
//				let y = y1 + ((y2 - y1) / (x2 - x1)) * (x - x1)
//				return y
//			}
//		}
//		return outputRange[length]
//	}
// }
//
// #Preview {
//	@Previewable @State var tabs: [TabModel] = [
////			.init(tabBarModel: .icon(.system("square.grid.2x2.fill"))),
//			.init(tabBarModel: .text("Followers")),
//			.init(tabBarModel: .text("Followings")),
////			.init(tabBarModel: .icon(.system("person.fill")))
//	]
//	ScrollTabBarView(
//		tabs: $tabs
//	)
// }
