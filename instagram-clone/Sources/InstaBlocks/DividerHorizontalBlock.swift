import Foundation
import Shared

public struct DividerHorizontalBlock: PostBlock, Equatable {
	public var id: String
	public var author: PostAuthor
	public var createdAt: Date
	public var updatedAt: Date? = nil
	public var caption: String
	public var media: [MediaItem]
	public var action: BlockActionWrapper?
	public var isSponsored: Bool
	public var type: String = PostLargeBlock.identifier
	public init(
		id: String = UUID().uuidString,
		author: PostAuthor = .empty,
		createdAt: Date = .now,
		caption: String = "",
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
	
	public static var identifier = "__divider_horizontal__"
}
