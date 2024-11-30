import DependenciesMacros
import Foundation
import Shared

@DependencyClient
public struct SnackbarMessagesClient: Sendable {
	public var snackbarMessages: @Sendable () async -> AsyncStream<[SnackbarMessage]> = { .never }
	public var show: @Sendable (_ message: SnackbarMessage) async -> Void
}
