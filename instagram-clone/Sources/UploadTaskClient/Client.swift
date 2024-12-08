import Foundation
import Shared
import DependenciesMacros

public enum UploadTask: Identifiable {
	case post(PostUploadTask)
	case avatar(AvatarUploadTask)
	public var id: String {
		switch self {
		case .post(let postUploadTask): return postUploadTask.id
		case .avatar(let avatarUploadTask): return avatarUploadTask.id
		}
	}
}

public struct PostUploadTask: Identifiable {
	public var postId: String
	public var caption: String
	public var files: [SelectedByte]
	public init(postId: String, caption: String, files: [SelectedByte]) {
		self.postId = postId
		self.caption = caption
		self.files = files
	}
	public var id: String {
		postId
	}
}

public struct AvatarUploadTask: Identifiable {
	public var id: String
	public var avatarImageData: Data?
	public init(id: String, avatarImageData: Data? = nil) {
		self.id = id
		self.avatarImageData = avatarImageData
	}
}

@DependencyClient
public struct UploadTaskClient: Sendable {
	public var uploadTask: @Sendable (_ task: UploadTask) async -> Void = { _ in }
	public var tasks: @Sendable () async -> AsyncStream<UploadTask> = { .init(unfolding: { nil }) }
}

