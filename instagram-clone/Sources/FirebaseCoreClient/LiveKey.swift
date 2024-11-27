import Foundation
import Dependencies
import FirebaseCore

extension FirebaseCoreClient: DependencyKey {
	public static let liveValue = FirebaseCoreClient(
		config: { FirebaseApp.configure() }
	)
}

