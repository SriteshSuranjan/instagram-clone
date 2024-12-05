import Foundation
import Dependencies
import Shared

extension UploadTaskClient: DependencyKey {
	public static let liveValue: UploadTaskClient = {
		let actor = UploadTaskActor()
		return UploadTaskClient(
			uploadTask: { task in actor.uploadTask(task) },
			tasks: { actor.tasks }
		)
	}()
}

private actor UploadTaskActor {
	private let (stream, continuation) = AsyncStream<UploadTask>.makeStream()
	var tasks: AsyncStream<UploadTask> {
		stream
	}
	func uploadTask(_ task: UploadTask) {
		continuation.yield(task)
	}
	deinit {
		continuation.finish()
	}
}
