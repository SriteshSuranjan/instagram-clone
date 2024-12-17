import Dependencies

extension DependencyValues {
	public var instagramClient: InstagramClient {
		get { self[InstagramClient.self] }
		set { self[InstagramClient.self] = newValue }
	}
}
