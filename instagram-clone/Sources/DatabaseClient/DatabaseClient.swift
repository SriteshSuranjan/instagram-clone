import Foundation
import Shared

public protocol DatabaseClient: Sendable {
	var currentUserId: String? { get async }
	func profile(of userId: String) async -> AsyncStream<User>
}
