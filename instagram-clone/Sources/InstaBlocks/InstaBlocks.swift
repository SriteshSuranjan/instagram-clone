import Foundation
import Shared

public protocol InstaBlock: Identifiable {
	var type: String { get }
}

public enum InstaBlockWrapper: Codable, Equatable, Identifiable, Hashable {
	case postLarge(PostLargeBlock)
	case postSponsored(PostSponsoredBlock)
	case horizontalDivider(DividerHorizontalBlock)
	case sectionHeader(SectionHeaderBlock)
	case postSmall(PostSmallBlock)
	case postReel(PostReelBlock)
	case unknown(UnknownBlock)
	
	private enum CodingKeys: String, CodingKey {
		case type
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
		switch type {
		case PostLargeBlock.identifier:
			self = .postLarge(try PostLargeBlock(from: decoder))
		case PostSponsoredBlock.identifier:
			self = .postSponsored(try PostSponsoredBlock(from: decoder))
		case DividerHorizontalBlock.identifier:
			self = .horizontalDivider(DividerHorizontalBlock())
		case SectionHeaderBlock.identifier:
			self = .sectionHeader(SectionHeaderBlock())
		case PostSmallBlock.identifier:
			self = .postSmall(try PostSmallBlock(from: decoder))
		case PostReelBlock.identifier:
			self = .postReel(try PostReelBlock(from: decoder))
		case UnknownBlock.identifier:
			self = .unknown(try UnknownBlock(from: decoder))
		default: fatalError("Unknown Block ")
		}
	}
	
	public func encode(to encoder: any Encoder) throws {
		switch self {
		case .postLarge(let postLargeBlock):
			try postLargeBlock.encode(to: encoder)
		case .postSponsored(let postSponsoredBlock):
			try postSponsoredBlock.encode(to: encoder)
		case .postSmall(let postSmallBlock):
			try postSmallBlock.encode(to: encoder)
		case .postReel(let postReelBlock):
			try postReelBlock.encode(to: encoder)
		case .unknown(let unknownBlock):
			try unknownBlock.encode(to: encoder)
		case .horizontalDivider:
			fatalError("divider block will not encode")
		case .sectionHeader:
			fatalError("section header block will not encode")
		}
	}
	
	public var id: String {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.id
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.id
		case .postReel(let postReelBlock): return postReelBlock.id
		case .unknown(let unknownBlock): return unknownBlock.id
		case .horizontalDivider(let dividerBlock): return dividerBlock.id
		case .sectionHeader(let sectionHeaderBlock): return sectionHeaderBlock.id
		case .postSmall(let postSmallBlock): return postSmallBlock.id
		}
	}
	
	public var media: [MediaItem]? {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.media
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.media
		case .postSmall(let postSmallBlock): return postSmallBlock.media
		case .postReel(let postReelBlock): return postReelBlock.media
		case .unknown: return nil
		case .horizontalDivider: return nil
		case .sectionHeader: return nil
		}
	}
	
	public var author: PostAuthor {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.author
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.author
		case .unknown(let unknownBlock): return unknownBlock.author
		case .horizontalDivider(let dividerBlock): return dividerBlock.author
		case .sectionHeader(let sectionHeaderBlock): return sectionHeaderBlock.author
		case .postSmall(let postSmallBlock): return postSmallBlock.author
		case .postReel(let postReelBlock): return postReelBlock.author
		}
	}
	
	public var createdAt: Date {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.createdAt
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.createdAt
		case .unknown(let unknownBlock): return unknownBlock.createdAt
		case .horizontalDivider(let dividerBlock): return dividerBlock.createdAt
		case .sectionHeader(let sectionHeaderBlock): return sectionHeaderBlock.createdAt
		case .postSmall(let postSmallBlock): return postSmallBlock.createdAt
		case .postReel(let postReelBlock): return postReelBlock.createdAt
		}
	}
	
	public var updatedAt: Date? {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.updatedAt
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.updatedAt
		case .unknown(let unknownBlock): return unknownBlock.updatedAt
		case .horizontalDivider(let dividerBlock): return dividerBlock.updatedAt
		case .sectionHeader(let sectionHeaderBlock): return sectionHeaderBlock.updatedAt
		case .postSmall(let postSmallBlock): return postSmallBlock.updatedAt
		case .postReel(let postReelBlock): return postReelBlock.updatedAt
		}
	}
	
	public var caption: String {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.caption
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.caption
		case .unknown(let unknownBlock): return unknownBlock.caption
		case .horizontalDivider(let dividerBlock): return dividerBlock.caption
		case .sectionHeader(let sectionHeaderBlock): return sectionHeaderBlock.caption
		case .postSmall(let postSmallBlock): return postSmallBlock.caption
		case .postReel(let postReelBlock): return postReelBlock.caption
		}
	}
	
	public var action: BlockActionWrapper? {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.action
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.action
		case .postSmall(let postSmallBlock): return postSmallBlock.action
		case .unknown(let unknownBlock): return unknownBlock.action
		case .postReel(let postReelBlock): return postReelBlock.action
		case .horizontalDivider: return nil
		case .sectionHeader: return nil
		}
	}
	
	public var isSponsored: Bool {
		switch self {
		case .postSponsored: return true
		default: return false
		}
	}
	
	public var mediaUrls: [String] {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.mediaUrls
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.mediaUrls
		case .postSmall(let postSmallBlock): return postSmallBlock.mediaUrls
		case .unknown(let unknownBlock): return unknownBlock.mediaUrls
		case .postReel(let postReelBlock): return postReelBlock.mediaUrls
		case .horizontalDivider: return []
		case .sectionHeader: return []
		}
	}
	
	public var isReel: Bool {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.isReel
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.isReel
		case .postSmall(let postSmallBlock): return postSmallBlock.isReel
		case .unknown(let unknownBlock): return unknownBlock.isReel
		case .postReel(let postReelBlock): return postReelBlock.isReel
		case .horizontalDivider: return false
		case .sectionHeader: return false
		}
	}
	
	public var block: any PostBlock {
		switch self {
		case .postReel(let postReelBlock): return postReelBlock
		case .postLarge(let postLargeBlock): return postLargeBlock
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock
		case .unknown(let unknownBlock): return unknownBlock
		case .horizontalDivider(let dividerBlock): return dividerBlock
		case .sectionHeader(let sectionHeaderBlock): return sectionHeaderBlock
		case .postSmall(let postSmallBlock): return postSmallBlock
		}
	}
}
