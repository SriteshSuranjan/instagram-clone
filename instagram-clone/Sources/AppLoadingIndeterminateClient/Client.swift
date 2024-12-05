import Foundation
import DependenciesMacros

@DependencyClient
public struct AppLoadingIndeterminateClient: Sendable {
	public var isLoading: @Sendable () async -> AsyncStream<Bool> = { .never }
	public var updateLoading: @Sendable (_ showLoading: Bool) async -> Void
}
