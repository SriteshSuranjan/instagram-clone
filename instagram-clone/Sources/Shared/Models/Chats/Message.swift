import Foundation

public enum MessageType: String {
	case text = "text"
	case image = "image"
	case video = "video"
	case voice = "voice"
}

extension String {
	public var toMessageType: MessageType {
		if let messageType = MessageType(rawValue: self) {
			return messageType
		}
		return .text
	}
}

public enum MessageAction: String, Equatable {
	case edit = "edit"
	case reply = "reply"
	case delete = "delete"
}

public struct Message: Identifiable, Equatable {
	public var id: String
	public var sender: PostAuthor?
	public var type: MessageType
	public var message: String
	public var replyMessageId: String?
	public var replyMessageUsername: String?
	public var replyMessageAttachmentUrl: String?
	public var createdAt: Date
	public var updatedAt: Date
	public var isRead: Bool
	public var isDeleted: Bool
	public var isEdited: Bool
	public var attachments: [Attachment]
	
	public init(
		id: String? = nil,
		sender: PostAuthor? = nil,
		type: MessageType = .text,
		message: String = "",
		replyMessageId: String? = nil,
		replyMessageUsername: String? = nil,
		replyMessageAttachmentUrl: String? = nil,
		createdAt: Date = .now,
		updatedAt: Date = .now,
		isRead: Bool = false,
		isDeleted: Bool = false,
		isEdited: Bool = false,
		attachments: [Attachment] = []
	) {
		self.id = id ?? UUID().uuidString.lowercased()
		self.sender = sender
		self.type = type
		self.message = message
		self.replyMessageId = replyMessageId
		self.replyMessageUsername = replyMessageUsername
		self.replyMessageAttachmentUrl = replyMessageAttachmentUrl
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.isRead = isRead
		self.isDeleted = isDeleted
		self.isEdited = isEdited
		self.attachments = attachments
	}
	
	public static let empty = Message()
}


