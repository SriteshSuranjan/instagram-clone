import Foundation
import Shared
import Dependencies

extension SnackbarMessagesClient: DependencyKey {
	public static let liveValue: SnackbarMessagesClient = {
		let actor = SnackbarMessageActor()
		return SnackbarMessagesClient(
			snackbarMessages: {
				actor.snackbarMessages
			},
			show: { snackbarMessage in
				actor.sendSnackbarMessage(snackbarMessage)
			}
		)
	}()
}

final private actor SnackbarMessageActor {
	private let (stream, continuation) = AsyncStream<[SnackbarMessage]>.makeStream()
	var snackbarMessages: AsyncStream<[SnackbarMessage]> {
		stream
	}
	func sendSnackbarMessage(_ message: SnackbarMessage) {
		continuation.yield([message])
	}
	deinit {
		continuation.finish()
	}
}

