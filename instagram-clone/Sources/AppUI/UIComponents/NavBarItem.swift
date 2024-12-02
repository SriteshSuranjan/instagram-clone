import Foundation
import Shared
import SwiftUI

public struct NavBarItemView<Child: View>: View {
	let label: String?
	let icon: AppIcon?
	let child: (() -> Child)?
	public init(
		label: String? = nil,
		icon: AppIcon? = nil,
		child: (() -> Child)? = nil
	) {
		self.label = label
		self.icon = icon
		self.child = child
	}

	public var body: some View {
//		Label {
//			if let label {
//				Text(label)
//			}
//		} icon: {
//			if let child {
//				child()
//			} else {
//				icon?.image
//			}
//		}
//		.frame(width: 28, height: 28)
//		.labelStyle(.iconOnly)
		Group {
			if let child {
				child()
			} else {
				icon?.image
			}
		}
			.frame(width: 28, height: 28)
	}
}
