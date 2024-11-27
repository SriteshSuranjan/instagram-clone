import Dependencies

public extension DependencyValues {
	var firebaseCore: FirebaseCoreClient {
		get { self[FirebaseCoreClient.self] }
		set { self[FirebaseCoreClient.self] = newValue }
	}
}

