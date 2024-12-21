import Foundation
import Dependencies

extension DependencyValues {
	public var feedUpdateRequestClient: FeedUpdateRequestClient {
		get { self[FeedUpdateRequestClient.self] }
		set { self[FeedUpdateRequestClient.self] = newValue }
	}
}
