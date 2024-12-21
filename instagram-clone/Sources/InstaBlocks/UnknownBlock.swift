import Foundation
import Shared
public struct UnknownBlock: PostBlock, Codable, Equatable {
	public var author: PostAuthor = .empty
	
	public var createdAt: Date = .now
	
	public var updatedAt: Date? = nil
	
	public var media: [MediaItem] = []
	
	public var caption: String = ""
	
	public var action: BlockActionWrapper? = nil
	
	public var isSponsored: Bool = false
	
	public var type: String = UnknownBlock.identifier
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.type = try container.decode(String.self, forKey: .type)
	}
	
	enum CodingKeys: CodingKey {
		case type
	}
	
	public static var identifier = "__unknown__"
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.type, forKey: .type)
	}
	public var id: String {
		UnknownBlock.identifier
	}
}
