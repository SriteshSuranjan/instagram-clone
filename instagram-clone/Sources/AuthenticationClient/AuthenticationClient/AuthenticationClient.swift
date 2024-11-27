import Foundation
import Shared

public protocol AuthenticationClient: Sendable {
	var user: AsyncStream<AuthenticationUser> { get }
	func logInWithPassword(_ password: String, email: String?, phone: String?) async throws -> Void
	func logInWithGoogle() async throws -> Void
	func logInWithGithub() async throws -> Void
	func signUpWithPassword(
		_ password: String,
		fullName: String,
		userName: String,
		avatarUrl: String?,
		email: String?,
		phone: String?,
		pushToken: String?
	) async throws -> Void
	func sendPasswordResetEmail(_ email: String, redirectTo: String?) async throws -> Void
	func resetPassword(token: String, email: String, newPassword: String) async throws -> Void
	func logOut() async throws -> Void
}
