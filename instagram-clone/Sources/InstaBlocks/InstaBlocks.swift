import Foundation
import Shared

public protocol InstaBlock: Identifiable {
	var type: String { get }
}

public enum InstaBlockWrapper: Codable, Equatable, Identifiable {
	case postLarge(PostLargeBlock)
	case postSponsored(PostSponsoredBlock)
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
		case .unknown(let unknownBlock):
			try unknownBlock.encode(to: encoder)
		}
	}
	
	public var id: String {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.id
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.id
		case .unknown(let unknownBlock): return unknownBlock.id
		}
	}
	
	public var media: [MediaItem]? {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.media
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.media
		case .unknown: return nil
		}
	}
	
	public var author: PostAuthor {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.author
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.author
		case .unknown(let unknownBlock): return unknownBlock.author
		}
	}
	
	public var createdAt: Date {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.createdAt
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.createdAt
		case .unknown(let unknownBlock): return unknownBlock.createdAt
		}
	}
	
	public var caption: String {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.caption
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.caption
		case .unknown(let unknownBlock): return unknownBlock.caption
		}
	}
	
	public var action: BlockActionWrapper? {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.action
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.action
		case .unknown(let unknownBlock): return unknownBlock.action
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
		case .unknown(let unknownBlock): return unknownBlock.mediaUrls
		}
	}
	
	public var isReel: Bool {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock.isReel
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock.isReel
		case .unknown(let unknownBlock): return unknownBlock.isReel
		}
	}
	
	public var block: any PostBlock {
		switch self {
		case .postLarge(let postLargeBlock): return postLargeBlock
		case .postSponsored(let postSponsoredBlock): return postSponsoredBlock
		case .unknown(let unknownBlock): return unknownBlock
		}
	}
}
