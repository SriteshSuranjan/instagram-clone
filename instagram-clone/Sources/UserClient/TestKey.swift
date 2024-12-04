import Dependencies

extension DependencyValues {
	public var userClient: UserClient {
		get { self[UserClient.self] }
		set { self[UserClient.self] = newValue }
	}
	public var userAuthClient: UserAuthClient {
		get { self[UserAuthClient.self] }
		set { self[UserAuthClient.self] = newValue }
	}
	public var userDatabaseClient: UserDatabaseClient {
		get { self[UserDatabaseClient.self] }
		set { self[UserDatabaseClient.self] = newValue }
	}
	public var storageUploaderClient: SupabaseStorageUploaderClient {
		get { self[SupabaseStorageUploaderClient.self] }
		set { self[SupabaseStorageUploaderClient.self] = newValue }
	}
}
