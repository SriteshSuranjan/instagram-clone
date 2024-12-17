import Foundation
import Shared

public struct PostLargeBlock: PostBlock, Equatable {
	public var id: String
	public var author: PostAuthor
	public var createdAt: Date
	public var caption: String
	public var media: [MediaItem]
	public var action: BlockActionWrapper?
	public var isSponsored: Bool
	public var type: String = PostLargeBlock.identifier
	public init(
		id: String,
		author: PostAuthor,
		createdAt: Date,
		caption: String,
		media: [MediaItem]? = nil,
		action: BlockActionWrapper? = nil,
		isSponsored: Bool = false
	) {
		self.id = id
		self.author = author
		self.createdAt = createdAt
		self.caption = caption
		self.action = action
		self.media = media ?? []
		self.isSponsored = isSponsored
	}
	
	public static var identifier = "__post_large__"
	
	enum CodingKeys: CodingKey {
		case id
		case author
		case createdAt
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
		caption = try container.decode(String.self, forKey: .caption)
		action = try container.decodeIfPresent(BlockActionWrapper.self, forKey: .action)
		media = try container.decode([MediaItem].self, forKey: .media)
		isSponsored = try container.decode(Bool.self, forKey: .isSponsored)
		type = "__post_large__"
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
	
//	public func hash(into hasher: inout Hasher) {
//		hasher.combine(id)
//		hasher.combine(author)
//		hasher.combine(createdAt)
//		hasher.combine(caption)
//		hasher.combine(action)
//		hasher.combine(isSponsored)
//		hasher.combine(type)
//		hasher.combine(media)
//	}
}
