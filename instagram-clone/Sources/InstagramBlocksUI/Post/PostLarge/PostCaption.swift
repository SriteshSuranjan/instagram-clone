import Foundation
import SwiftUI
import AppUI

public struct PostCaption: View {
	let username: String
	let caption: String
	@Environment(\.textTheme) var textTheme
	public var body: some View {
		Group {
			Text(username)
				.font(textTheme.titleMedium.font)
				.fontWeight(.semibold)
			+
			Text(" \(caption)")
				.font(textTheme.bodyMedium.font)
		}
		.foregroundStyle(Assets.Colors.bodyColor)
	}
}
