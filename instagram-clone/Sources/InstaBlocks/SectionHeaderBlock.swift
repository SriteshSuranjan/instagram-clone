import Foundation
import Shared

public enum SectionHeaderBlockType {
	case suggested
}

public struct SectionHeaderBlock: PostBlock, Equatable {
	public var author: PostAuthor
	
	public var id: String
	
	public var createdAt: Date
	
	public var updatedAt: Date? = nil
	
	public var media: [Shared.MediaItem]
	
	public var caption: String
	
	public var action: BlockActionWrapper?
	
	public var isSponsored: Bool
	
	public var type: String
	
	public var sectionType: SectionHeaderBlockType
	
	public init(
		author: PostAuthor = .empty,
		id: String = UUID().uuidString,
		createdAt: Date = .now,
		media: [Shared.MediaItem] = [],
		caption: String = "",
		action: BlockActionWrapper? = nil,
		isSponsored: Bool = false,
		sectionType: SectionHeaderBlockType = .suggested,
		type: String = SectionHeaderBlock.identifier
	) {
		self.author = author
		self.id = id
		self.createdAt = createdAt
		self.media = media
		self.caption = caption
		self.action = action
		self.isSponsored = isSponsored
		self.sectionType = sectionType
		self.type = type
	}
	
	public static var identifier = "__section_header__"
}
