import Foundation
import Shared

extension Post {
	public func toPostReelBlock() -> PostReelBlock {
		PostReelBlock(
			id: id,
			author: PostAuthor(
				confirmed: author.id,
				avatarUrl: author.avatarUrl,
				username: author.username
			),
			createdAt: createdAt,
			updatedAt: updatedAt,
			caption: caption,
			media: media,
			action: .navigateToPostAuthor(
				NavigateToPostAuthorProfileAction(
					authorId: author.id
				)
			)
		)
	}
}

public struct PostReelBlock: PostBlock, Equatable {
	public var author: PostAuthor
	
	public var id: String
	
	public var createdAt: Date
	
	public var media: [Shared.MediaItem]
	
	public var caption: String
	
	public var action: BlockActionWrapper?
	
	public var isSponsored: Bool
	
	public var updatedAt: Date?
	
	public var type: String = PostReelBlock.identifier
	
	public init(
		id: String,
		author: PostAuthor,
		createdAt: Date,
		updatedAt: Date? = nil,
		caption: String,
		media: [MediaItem]? = nil,
		action: BlockActionWrapper? = nil,
		isSponsored: Bool = false
	) {
		self.id = id
		self.author = author
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.caption = caption
		self.action = action
		self.media = media ?? []
		self.isSponsored = isSponsored
	}
	
	public static var identifier: String {
		"__post_reel__"
	}
	
	enum CodingKeys: CodingKey {
		case id
		case author
		case createdAt
		case updatedAt
		case caption
		case action
		case isSponsored
		case media
		case type
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		author = try container.decode(PostAuthor.self, forKey: .author, configuration: .normal)
		createdAt = try container.decode(Date.self, forKey: .createdAt)
		updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
		caption = try container.decode(String.self, forKey: .caption)
		action = try container.decodeIfPresent(BlockActionWrapper.self, forKey: .action)
		media = try container.decode([MediaItem].self, forKey: .media)
		isSponsored = try container.decode(Bool.self, forKey: .isSponsored)
		type = "__post_reel__"
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.author, forKey: .author)
		try container.encode(self.createdAt, forKey: .createdAt)
		try container.encode(self.caption, forKey: .caption)
		try container.encodeIfPresent(self.action, forKey: .action)
		try container.encode(self.isSponsored, forKey: .isSponsored)
		try container.encode(self.type, forKey: .type)
		try container.encode(self.media, forKey: .media)
	}
}
