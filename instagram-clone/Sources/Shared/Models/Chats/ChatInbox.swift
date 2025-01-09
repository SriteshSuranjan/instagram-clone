import Foundation

public enum ChatType: String {
	case oneOnOne = "one-on-one"
	case group = "group"
}

extension String {
	public var toChatType: ChatType {
		if let chatType = ChatType(rawValue: self) {
			return chatType
		}
		return .oneOnOne
	}
}

public struct ChatInbox: Identifiable, Equatable {
	public var id: String
	public var type: ChatType
	public var lastMessage: String?
	public var unreadMessagesCount: Int
	public var participant: User
	public init(
		id: String? = nil,
		type: String?,
		lastMessage: String? = nil,
		unreadMessagesCount: Int,
		participant: User
	) {
		self.id = id ?? UUID().uuidString.lowercased()
		self.type = type?.toChatType ?? .oneOnOne
		self.lastMessage = lastMessage
		self.unreadMessagesCount = unreadMessagesCount
		self.participant = participant
	}
}
