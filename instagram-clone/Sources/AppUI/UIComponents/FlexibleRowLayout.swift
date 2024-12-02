import Foundation
import SwiftUI

public struct FlexibleRowLayout: Layout {
	struct Flex: LayoutValueKey {
		static let defaultValue: Int = 1
		let value: Int
	}
	
	public init() {
		
	}
		
	public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
		let totalFlex = subviews.map { $0[Flex.self] }.reduce(0, +)
		let spacing = CGFloat(subviews.count - 1) * AppSpacing.sm // 假设间距为8
		let availableWidth = (proposal.width ?? 0) - spacing
				
		let height = subviews.map { subview in
			let flex = subview[Flex.self]
			let width = (availableWidth * CGFloat(flex)) / CGFloat(totalFlex)
			return subview.sizeThatFits(.init(width: width, height: proposal.height)).height
		}.max() ?? 0
				
		return CGSize(width: proposal.width ?? 0, height: height)
	}
		
	public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
		let totalFlex = subviews.map { $0[Flex.self] }.reduce(0, +)
		let spacing = CGFloat(subviews.count - 1) * AppSpacing.sm
		let availableWidth = bounds.width - spacing
				
		var x = bounds.minX
		for subview in subviews {
			let flex = subview[Flex.self]
			let width = (availableWidth * CGFloat(flex)) / CGFloat(totalFlex)
						
			subview.place(
				at: CGPoint(x: x, y: bounds.minY),
				proposal: .init(width: width, height: bounds.height)
			)
						
			x += width + 8 // 8是间距
		}
	}
}

// 扩展 View 以添加 flex 修饰符
public extension View {
	func flex(_ flex: Int) -> some View {
		layoutValue(key: FlexibleRowLayout.Flex.self, value: FlexibleRowLayout.Flex(value: flex).value)
	}
}
