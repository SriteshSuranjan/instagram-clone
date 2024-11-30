import Dependencies
import Foundation

public extension DependencyValues {
	var snackbarMessagesClient: SnackbarMessagesClient {
		get { self[SnackbarMessagesClient.self] }
		set { self[SnackbarMessagesClient.self] = newValue }
	}
}
