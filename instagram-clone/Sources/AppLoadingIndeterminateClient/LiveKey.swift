import Foundation
import Dependencies

extension AppLoadingIndeterminateClient: DependencyKey {
	public static let liveValue: AppLoadingIndeterminateClient = {
		let actor = LoadingActor()
		debugPrint("AppLoadingIndeterminateClient creating liveValue, actor: \(Unmanaged.passUnretained(actor).toOpaque())")
		return AppLoadingIndeterminateClient(
			isLoading: {
				debugPrint("AppLoadingIndeterminateClient get isLoading, actor: \(Unmanaged.passUnretained(actor).toOpaque())")
				return actor.isLoading
			},
			updateLoading: { showLoading in
				debugPrint("AppLoadingIndeterminateClient update isLoading, actor: \(Unmanaged.passUnretained(actor).toOpaque())")
				actor.updateLoading(showLoading)
			}
		)
	}()
}

private actor LoadingActor {
	private let (stream, continuation) = AsyncStream<Bool>.makeStream()
	var isLoading: AsyncStream<Bool> {
		stream
	}
	func updateLoading(_ loading: Bool) {
		debugPrint("AppLoadingIndeterminateClient \(loading) \(#line)")
		continuation.yield(loading)
	}
	deinit {
		debugPrint("AppLoadingIndeterminateClient finish, actor: \(Unmanaged.passUnretained(self).toOpaque())")
		continuation.finish()
	}
}
