import Dependencies

extension DependencyValues {
	public var uploadTaskClient: UploadTaskClient {
		get { self[UploadTaskClient.self] }
		set { self[UploadTaskClient.self] = newValue }
	}
}
