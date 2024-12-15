import Foundation
import Shared

public protocol BlockPage: Equatable, Codable {
	var blocks: [InstaBlockWrapper] { get }
	var totalBlocks: Int { get }
	var page: Int { get }
	var hasMore: Bool { get }
	init(
		blocks: [InstaBlockWrapper],
		totalBlocks: Int,
		page: Int,
		hasMore: Bool
	)
}

extension BlockPage {
	static var empty: Self {
		Self(blocks: [], totalBlocks: 0, page: 0, hasMore: false)
	}
}

private enum CodingKeys: CodingKey {
	case blocks
	case totalBlocks
	case page
	case hasMore
}

extension BlockPage {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(blocks, forKey: .blocks)
		try container.encode(totalBlocks, forKey: .totalBlocks)
		try container.encode(page, forKey: .page)
		try container.encode(hasMore, forKey: .hasMore)
	}
}

public struct FeedPage: BlockPage, Equatable, Codable {
	public var blocks: [InstaBlockWrapper]
	public var totalBlocks: Int
	public var page: Int
	public var hasMore: Bool
	public init(
		blocks: [InstaBlockWrapper],
		totalBlocks: Int,
		page: Int,
		hasMore: Bool
	) {
		self.blocks = blocks
		self.totalBlocks = totalBlocks
		self.page = page
		self.hasMore = hasMore
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.blocks = try container.decode([InstaBlockWrapper].self, forKey: .blocks)
		self.totalBlocks = try container.decode(Int.self, forKey: .totalBlocks)
		self.page = try container.decode(Int.self, forKey: .page)
		self.hasMore = try container.decode(Bool.self, forKey: .hasMore)
	}
}

public struct ReelsPage: BlockPage {
	public var blocks: [InstaBlockWrapper]
	public var totalBlocks: Int
	public var page: Int
	public var hasMore: Bool
	public init(
		blocks: [InstaBlockWrapper],
		totalBlocks: Int,
		page: Int,
		hasMore: Bool
	) {
		self.blocks = blocks
		self.totalBlocks = totalBlocks
		self.page = page
		self.hasMore = hasMore
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.blocks = try container.decode([InstaBlockWrapper].self, forKey: .blocks)
		self.totalBlocks = try container.decode(Int.self, forKey: .totalBlocks)
		self.page = try container.decode(Int.self, forKey: .page)
		self.hasMore = try container.decode(Bool.self, forKey: .hasMore)
	}
}


public struct Feed: Equatable {
	public var feedPage: FeedPage
	public var reelsPage: ReelsPage
	public static let empty = Feed(feedPage: .empty, reelsPage: .empty)
	public init(feedPage: FeedPage, reelsPage: ReelsPage) {
		self.feedPage = feedPage
		self.reelsPage = reelsPage
	}
}
