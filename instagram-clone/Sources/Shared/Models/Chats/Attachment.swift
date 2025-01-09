import Foundation

public enum AttachmentType: String {
	case image
	case file
	case giphy
	case video
	case audio
	case urlPreview = "url_preview"
}

public extension String {
	var toAttachmentType: AttachmentType? {
		AttachmentType(rawValue: self)
	}
}

public enum UploadState: Equatable {
	case preparing
	case inProgress(uploaded: Int, total: Int)
	case success
	case failed(error: String)
}

public struct Attachment: Identifiable, Equatable {
	public var id: String
	public var type: String?
	public var titleLink: String?
	public var title: String?
	public var thumbUrl: String?
	public var text: String?
	public var preText: String?
	public var ogScrapeUrl: String?
	public var imageUrl: String?

	public var footerIcon: String?
	public var footer: String?
	public var fallback: String?
	public var color: String?

	/// The name of the author.
	public var authorName: String?
	public var authorLink: String?
	public var authorIcon: String?
	public var assetUrl: String?
	
	public var attachmentFile: AttachmentFile?
//	public var extraData: [String: Any]?
	public var uploadState: UploadState?
	
	public init(
		id: String?,
		type: String? = nil,
		titleLink: String? = nil,
		title: String? = nil,
		thumbUrl: String? = nil,
		text: String? = nil,
		preText: String? = nil,
		ogScrapeUrl: String? = nil,
		imageUrl: String? = nil,
		footerIcon: String? = nil,
		footer: String? = nil,
		fallback: String? = nil,
		color: String? = nil,
		authorName: String? = nil,
		authorLink: String? = nil,
		authorIcon: String? = nil,
		assetUrl: String? = nil,
		attachmentFile: AttachmentFile? = nil,
//		extraData: [String : Any]? = nil,
		uploadState: UploadState? = nil
	) {
		self.id = id ?? UUID().uuidString.lowercased()
		self.type = type
		self.titleLink = titleLink
		self.title = title ?? attachmentFile?.name
		self.thumbUrl = thumbUrl
		self.text = text
		self.preText = preText
		self.ogScrapeUrl = ogScrapeUrl
		self.imageUrl = imageUrl
		self.footerIcon = footerIcon
		self.footer = footer
		self.fallback = fallback
		self.color = color
		self.authorName = authorName
		self.authorLink = authorLink
		self.authorIcon = authorIcon
		self.assetUrl = assetUrl
		self.attachmentFile = attachmentFile
//		self.extraData = extraData
		self.uploadState = uploadState
	}
}

public struct AttachmentFile: Equatable {
	public var path: String?
	public var name: String?
	public var bytes: Data?
	public var size: Int?
	public init(path: String? = nil, name: String? = nil, bytes: Data? = nil, size: Int? = nil) {
		self.path = path
		self.name = name
		self.bytes = bytes
		self.size = size
	}
}
