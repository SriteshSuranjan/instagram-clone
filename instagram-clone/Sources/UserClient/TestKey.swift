import Dependencies

extension DependencyValues {
	public var userClient: UserClient {
		get { self[UserClient.self] }
		set { self[UserClient.self] = newValue }
	}
}
