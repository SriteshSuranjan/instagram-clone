import Foundation
import DependenciesMacros
import Shared
import AuthenticationClient
import Supabase

@DependencyClient
public struct UserClient: Sendable {
	public var user: @Sendable () -> AsyncStream<Shared.User> = { .never }
	public var authStateChanges: @Sendable () -> AsyncStream<AuthChangeEvent> = { .never }
	public var logInWithGoogle: @Sendable () async throws -> Void
	public var logInWithGithub: @Sendable () async throws -> Void
	public var logInWithPassword: @Sendable (_ password: String, _ email: String?, _ phone: String) async throws -> Void
	public var signUpWithPassword: @Sendable (_ password: String, _ fullName: String, _ username: String, _ avatarUrl: String?, _ email: String?, _ phone: String?, _ pushToken: String?) async throws -> Void
	public var sendPasswordResetEmail: @Sendable (_ email: String, _ redirectTo: String?) async throws -> Void
	public var resetPassword: @Sendable (_ token: String, _ email: String, _ newPassword: String) async throws -> Void
	public var logOut: @Sendable () async throws -> Void
}
