import Foundation

public protocol TokenStorage: Sendable {
	func readToken() async throws -> String?
	func saveToken(_ token: String) async throws -> Void
	func clearToken() async throws -> Void
}


public actor InMemoryTokenStorage: TokenStorage {
	private var token: String?
	public init() {
		self.token = nil
	}
	public func readToken() async throws -> String? {
		token
	}
	public func saveToken(_ token: String) async throws {
		self.token = token
	}
	public func clearToken() async throws {
		self.token = nil
	}
}
