import Foundation
import Shared

public struct PostSponsoredBlock: PostBlock, Codable, Equatable {
	public var author: PostAuthor
	
	public var id: String
	
	public var createdAt: Date
	
	public var updatedAt: Date? = nil
	
	public var media: [Shared.MediaItem]
	
	public var caption: String
	
	public var action: BlockActionWrapper?
	
	public var isSponsored: Bool
	
	public var type: String = PostSponsoredBlock.identifier
	
	public init(
		author: PostAuthor,
		id: String,
		createdAt: Date,
		media: [MediaItem],
		caption: String,
		action: BlockActionWrapper? = nil,
		isSponsored: Bool
	) {
		self.author = author
		self.id = id
		self.createdAt = createdAt
		self.media = media
		self.caption = caption
		self.action = action
		self.isSponsored = isSponsored
	}
	
	public static var identifier: String {
		"__post_sponsored__"
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
	}
	enum CodingKeys: CodingKey {
		case author
		case id
		case createdAt
		case media
		case caption
		case action
		case isSponsored
		case type
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.author, forKey: .author)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.createdAt, forKey: .createdAt)
		try container.encode(self.media, forKey: .media)
		try container.encode(self.caption, forKey: .caption)
		try container.encodeIfPresent(self.action, forKey: .action)
		try container.encode(self.isSponsored, forKey: .isSponsored)
		try container.encode(self.type, forKey: .type)
	}
}
