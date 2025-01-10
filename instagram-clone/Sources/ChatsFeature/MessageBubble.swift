import AppUI
import Foundation
import Shared
import SwiftUI

public struct MessageBubble: View {
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public let message: Message
	public let isMine: Bool
	@State private var bubbleWidth: CGFloat = 0
	public init(isMine: Bool, message: Message) {
		self.isMine = isMine
		self.message = message
	}

	public var body: some View {
			messageContent()
				.fixedSize(horizontal: false, vertical: true)
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
	private func messageContent() -> some View {
		Text(message.message)
			
			.lineLimit(nil)
			.multilineTextAlignment(.leading)
			.font(textTheme.bodyLarge.font)
			.fontWeight(.semibold)
			.foregroundStyle(Assets.Colors.bodyColor)
			.padding()
			.background(Assets.Colors.blue.gradient)
	}
}
