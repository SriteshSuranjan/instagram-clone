import Foundation
import DependenciesMacros
import Sharing

@DependencyClient
public struct AppLoadingIndeterminateClient: Sendable {
	public var isLoading: @Sendable () async -> AsyncStream<Bool> = { .never }
	public var updateLoading: @Sendable (_ showLoading: Bool) async -> Void
}

extension SharedKey {
	public static func appLoading() -> Self where Self == InMemoryKey<Bool>.Default {
		Self[.inMemory("appLoading"), default: false]
	}
}
