import Foundation
import DependenciesMacros
import Dependencies

@DependencyClient
public struct FirebaseCoreClient: Sendable {
	public var config: @Sendable () -> Void
}
