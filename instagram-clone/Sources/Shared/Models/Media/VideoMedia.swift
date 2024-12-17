import Foundation

public struct VideoMedia: Media {
	public var id: String
	
	public var url: String
	
	public var blurHash: String?
	
	public var type: String = VideoMedia.identifier
	
	public var firstFrameUrl: String?
	
	public init(id: String, url: String, blurHash: String?, firstFrameUrl: String?) {
		self.id = id
		self.url = url
		self.blurHash = blurHash
		self.firstFrameUrl = firstFrameUrl
	}
	
	public static var identifier: String {
		"__video_media__"
	}
	
	public var previewData: Data? { nil }
	
	private enum CodingKeys: String, CodingKey {
		case id = "mediaId"
		case url
		case type
		case blurHash
		case firstFrameUrl
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.url = try container.decode(String.self, forKey: .url)
		self.blurHash = try container.decodeIfPresent(String.self, forKey: .blurHash)
		self.type = try container.decode(String.self, forKey: .type)
		self.firstFrameUrl = try container.decodeIfPresent(String.self, forKey: .firstFrameUrl)
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.url, forKey: .url)
		try container.encode(self.type, forKey: .type)
		try container.encodeIfPresent(self.blurHash, forKey: .blurHash)
		try container.encodeIfPresent(firstFrameUrl, forKey: .firstFrameUrl)
	}
	
}
