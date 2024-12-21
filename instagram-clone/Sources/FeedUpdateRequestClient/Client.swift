import Foundation
import Shared
import DependenciesMacros

public enum FeedUpdateRequest: Identifiable {
	case create(newPost: Post)
	case delete(postId: String)
	case update(newPost: Post)
	public var id: String {
		switch self {
		case .create(let newPost): return newPost.id
		case .delete(let postId): return postId
		case .update(let newPost): return newPost.id
		}
	}
}

@DependencyClient
public struct FeedUpdateRequestClient: Sendable {
	public var addFeedUpdateRequest: @Sendable (_ request: FeedUpdateRequest) async -> Void
	public var feedUpdateRequests: @Sendable () async -> AsyncStream<FeedUpdateRequest> = { .never }
}
