import Foundation
import SwiftUI
import Shared
import AppUI
import InstagramBlocksUI

public struct ChatInboxTile: View {
	public let chat: ChatInbox
	@Environment(\.textTheme) var textTheme
	public init(chat: ChatInbox) {
		self.chat = chat
	}
	public var body: some View {
		HStack {
			UserProfileAvatar(
				userId: self.chat.participant.id,
				avatarUrl: self.chat.participant.avatarUrl,
				radius: 26
			)
			.foregroundStyle(Assets.Colors.bodyColor)
			VStack(alignment: .leading, spacing: AppSpacing.xs) {
				Text(self.chat.participant.displayUsername)
					.font(textTheme.titleLarge.font)
					.fontWeight(.semibold)
					.foregroundStyle(Assets.Colors.bodyColor)
				Text(chat.lastMessage ?? "No last messages")
					.font(textTheme.bodyLarge.font)
					.fontWeight(.medium)
					.foregroundStyle(Assets.Colors.gray)
			}
			Spacer()
		}
	}
}
