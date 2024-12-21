import Foundation
import Shared
import Dependencies

extension FeedUpdateRequestClient: DependencyKey {
	public static let liveValue: FeedUpdateRequestClient = {
		let actor = FeedUpdateRequestActor()
		return FeedUpdateRequestClient(
			addFeedUpdateRequest: { request in
				actor.addRequest(request)
			},
			feedUpdateRequests: {
				actor.requests
			}
		)
	}()
}

private actor FeedUpdateRequestActor {
	private let (stream, continuation) = AsyncStream<FeedUpdateRequest>.makeStream()
	fileprivate var requests: AsyncStream<FeedUpdateRequest> {
		stream
	}
	fileprivate func addRequest(_ request: FeedUpdateRequest) {
		continuation.yield(request)
	}
	deinit {
		continuation.finish()
	}
}
