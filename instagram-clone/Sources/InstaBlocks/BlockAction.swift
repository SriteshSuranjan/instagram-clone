import Foundation

public enum BlockActionType: String, Encodable {
	case navigation
	case unknown
}

public protocol BlockAction: Equatable, Codable {
	var type: String { get }
	var actionType: BlockActionType { get }
}

public enum BlockActionWrapper: Codable, Equatable {
	case navigateToPostAuthor(NavigateToPostAuthorProfileAction)
	case navigateToSponsor(NavigateToSponsoredPostAuthorProfileAction)
	case unknown(UnknownBlockAction)
	
	private enum CodingKeys: String, CodingKey {
		case type
	}
			
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
					
		switch type {
		case "__navigate_to_author__":
			self = try .navigateToPostAuthor(NavigateToPostAuthorProfileAction(from: decoder))
		case "__navigate_to_sponsored_author__":
			self = try .navigateToSponsor(NavigateToSponsoredPostAuthorProfileAction(from: decoder))
		case "__unknown__":
			self = try .unknown(UnknownBlockAction(from: decoder))
		default: fatalError("Unknown Block Action")
		}
	}
	
	public func encode(to encoder: any Encoder) throws {
		switch self {
		case .navigateToPostAuthor(let navigateToPostAuthorProfileAction):
			try navigateToPostAuthorProfileAction.encode(to: encoder)
		case .navigateToSponsor(let navigateToSponsoredPostAuthorProfileAction):
			try navigateToSponsoredPostAuthorProfileAction.encode(to: encoder)
		case .unknown(let unknownBlockAction):
			try unknownBlockAction.encode(to: encoder)
		}
	}
}

public struct NavigateToPostAuthorProfileAction: BlockAction {
	public var type: String
	public var actionType: BlockActionType
	public var authorId: String
	public init(
		type: String = "__navigate_to_author__",
		actionType: BlockActionType = .navigation,
		authorId: String
	) {
		self.type = type
		self.actionType = actionType
		self.authorId = authorId
	}
	
	private enum CodingKeys: CodingKey {
		case authorId
		case type
		case actionType
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.authorId = try container.decode(String.self, forKey: .authorId)
		self.type = try container.decode(String.self, forKey: .type)
		self.actionType = BlockActionType(rawValue: try container.decode(String.self, forKey: .actionType))!
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.authorId, forKey: .authorId)
		try container.encode(self.type, forKey: .type)
		try container.encode(self.actionType, forKey: .actionType)
	}
}

public struct NavigateToSponsoredPostAuthorProfileAction: BlockAction {
	public var type: String
	public var actionType: BlockActionType
	public var authorId: String
	public var promoPreviewImageUrl: String
	public var promoUrl: String
	public init(
		type: String = "__navigate_to_sponsored_author__",
		actionType: BlockActionType = .navigation,
		authorId: String,
		promoPreviewImageUrl: String,
		promoUrl: String
	) {
		self.type = type
		self.actionType = actionType
		self.authorId = authorId
		self.promoPreviewImageUrl = promoPreviewImageUrl
		self.promoUrl = promoUrl
	}
	
	enum CodingKeys: CodingKey {
		case type
		case actionType
		case authorId
		case promoPreviewImageUrl
		case promoUrl
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.authorId = try container.decode(String.self, forKey: .authorId)
		self.promoPreviewImageUrl = try container.decode(String.self, forKey: .promoPreviewImageUrl)
		self.promoUrl = try container.decode(String.self, forKey: .promoUrl)
		self.type = "__navigate_to_sponsored_author__"
		self.actionType = .navigation
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.type, forKey: .type)
		try container.encode(self.actionType, forKey: .actionType)
		try container.encode(self.authorId, forKey: .authorId)
		try container.encode(self.promoPreviewImageUrl, forKey: .promoPreviewImageUrl)
		try container.encode(self.promoUrl, forKey: .promoUrl)
	}
}

public struct UnknownBlockAction: BlockAction {
	public var type: String
	public var actionType: BlockActionType
	public init(type: String = "__unknown__", actionType: BlockActionType = .unknown) {
		self.type = type
		self.actionType = actionType
	}

	public init(from decoder: any Decoder) throws {
		self.type = "__unknown__"
		self.actionType = .unknown
	}
	
	enum CodingKeys: CodingKey {
		case type
		case actionType
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.type, forKey: .type)
		try container.encode(self.actionType, forKey: .actionType)
	}
}
