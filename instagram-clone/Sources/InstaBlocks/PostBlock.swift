import Foundation
import Shared

public protocol PostBlock: InstaBlock, Equatable, Hashable {
	var author: PostAuthor { get }
	var id: String { get }
	var createdAt: Date { get }
	var media: [MediaItem] { get }
	var caption: String { get }
	var action: BlockActionWrapper? { get }
	var isSponsored: Bool { get }
}

extension PostBlock {
	public var isReel: Bool {
		media.count == 1 && media.first!.isVideo
	}
	public var firstMedia: MediaItem? {
		media.first
	}
	public var firstMediaUrl: String? {
		if case let .video(item) = firstMedia {
			return item.firstFrameUrl
		}
		return firstMedia?.url
	}
	public var mediaUrls: [String] {
		media.map(\.url)
	}
	public var hasBothMediaType: Bool {
		!media.allSatisfy { $0.isVideo } &&
		!media.allSatisfy { !$0.isVideo }
	}
}
