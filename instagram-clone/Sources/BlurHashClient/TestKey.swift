import Dependencies

extension DependencyValues {
	public var blurHashClient: BlurHashClient {
		get { self[BlurHashClient.self] }
		set { self[BlurHashClient.self] = newValue }
	}
}
