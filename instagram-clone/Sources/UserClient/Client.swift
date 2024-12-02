import AuthenticationClient
import DatabaseClient
import DependenciesMacros
import Foundation
import Shared
import Supabase

@DependencyClient
public struct UserClient: Sendable {
	public let authClient: UserAuthClient
	public let databaseClient: UserDatabaseClient
}

@DependencyClient
public struct UserAuthClient: Sendable {
	public var user: @Sendable () -> AsyncStream<Shared.User> = { .never }
	public var logInWithGoogle: @Sendable () async throws -> Void
	public var logInWithGithub: @Sendable () async throws -> Void
	public var logInWithPassword: @Sendable (_ password: String, _ email: String?, _ phone: String) async throws -> Void
	public var signUpWithPassword: @Sendable (_ password: String, _ fullName: String, _ username: String, _ avatarUrl: String?, _ email: String?, _ phone: String?, _ pushToken: String?) async throws -> Void
	public var sendPasswordResetEmail: @Sendable (_ email: String, _ redirectTo: String?) async throws -> Void
	public var resetPassword: @Sendable (_ token: String, _ email: String, _ newPassword: String) async throws -> Void
	public var logOut: @Sendable () async throws -> Void
}

@DependencyClient
public struct UserDatabaseClient: Sendable {
	public var currentUserId: @Sendable () async -> String?
	public var isOwner: @Sendable (_ userId: String) async -> Bool = { _ in false }
	public var profile: @Sendable (_ userId: String) async -> AsyncStream<Shared.User> = { _ in .never }
}
