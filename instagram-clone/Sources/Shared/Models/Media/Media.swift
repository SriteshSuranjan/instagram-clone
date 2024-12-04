import Foundation

public protocol Media: Equatable, Codable {
	var id: String { get }
	var url: URL { get }
	var blurHash: String? { get }
	static var identifier: String { get }
}

public enum MediaItem: Equatable, Codable {
	case memoryImage(MemoryImageMedia)
	case memoryVideo(MemoryVideoMedia)
	
	public var id: String {
		switch self {
		case .memoryImage(let memoryImageMedia): return memoryImageMedia.id
		case .memoryVideo(let memoryVideoMedia): return memoryVideoMedia.id
		}
	}
	
	public var url: URL {
		switch self {
		case .memoryImage(let memoryImageMedia): return memoryImageMedia.url
		case .memoryVideo(let memoryVideoMedia): return memoryVideoMedia.url
		}
	}
	
	public var blurHash: String? {
		switch self {
		case .memoryImage(let memoryImageMedia): return memoryImageMedia.blurHash
		case .memoryVideo(let memoryVideoMedia): return memoryVideoMedia.blurHash
		}
	}
}

public struct MemoryImageMedia: Media {
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
}
