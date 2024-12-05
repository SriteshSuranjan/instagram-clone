
import Foundation
import Dependencies

extension DependencyValues {
	public var appLoadingIndeterminateClient: AppLoadingIndeterminateClient {
		get { self[AppLoadingIndeterminateClient.self] }
		set { self[AppLoadingIndeterminateClient.self] = newValue }
	}
}
