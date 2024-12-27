import Foundation

public struct Comment: Equatable, Identifiable {
	public let id: String
	public let postId: String
	public let author: PostAuthor
	public let repliedToCommentId: String?
	public let replies: Int?
	public let content: String
	public let createdAt: Date
	
	public init(
		id: String,
		postId: String,
		author: PostAuthor,
		repliedToCommentId: String?,
		replies: Int?,
		content: String,
		createdAt: Date
	) {
		self.id = id
		self.postId = postId
		self.author = author
		self.repliedToCommentId = repliedToCommentId
		self.replies = replies
		self.content = content
		self.createdAt = createdAt
	}
	
	public var isReplied: Bool {
		repliedToCommentId != nil
	}
}
