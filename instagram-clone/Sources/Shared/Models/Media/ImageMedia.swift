import Foundation

public struct ImageMedia: Media, Codable {
	public var id: String
	
	public var url: String
	
	public var type: String = ImageMedia.identifier
	
	public var blurHash: String?
	
	public init(id: String, url: String, blurHash: String?) {
		self.id = id
		self.url = url
		self.blurHash = blurHash
	}
	
	private enum CodingKeys: String, CodingKey {
		case id = "mediaId"
		case url
		case type
		case blurHash = "blurHash"
	}
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		url = try container.decode(String.self, forKey: .url)
		type = try container.decode(String.self, forKey: .type)
		blurHash = try container.decodeIfPresent(String.self, forKey: .blurHash)
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(url, forKey: .url)
		try container.encode(type, forKey: .type)
		try container.encodeIfPresent(blurHash, forKey: .blurHash)
	}
	
	public static var identifier: String {
		"__image_media__"
	}
	
	public var previewData: Data? { nil }
}

/*public struct MemoryImageMedia: Media {
 public static var identifier: String {
		"__memory_image_media__"
	}

	public var id: String
	public var url: URL
	public var blurHash: String?
	public init(id: String, url: URL, blurHash: String? = nil) {
		self.id = id
		self.url = url
		self.blurHash = blurHash
	}

	public var type: String {
		MemoryImageMedia.identifier
	}
}

public struct MemoryVideoMedia: Media {
	public static var identifier: String {
		"__memory_video_media__"
	}

	public var id: String
	public var url: URL
	public var blurHash: String?
	public init(id: String, url: URL, blurHash: String? = nil) {
		self.id = id
		self.url = url
		self.blurHash = blurHash
	}

	public var type: String {
		MemoryVideoMedia.identifier
	}
}*/
