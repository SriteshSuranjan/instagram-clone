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
	public let storageUploaderClient: SupabaseStorageUploaderClient
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
	public var postsCount: @Sendable (_ userId: String) async -> AsyncStream<Int> = { _ in .never }
	public var followersCount: @Sendable (_ userId: String) async -> AsyncStream<Int> = { _ in .never }
	public var followingsCount: @Sendable (_ userId: String) async -> AsyncStream<Int> = { _ in .never }
	public var followingStatus: @Sendable (_ userId: String, _ followerId: String?) async -> AsyncStream<Bool> = { _, _ in .never }
	public var isFollowed: @Sendable (_ followerId: String, _ userId: String) async throws -> Bool
	public var follow: @Sendable (_ followedToId: String, _ followerId: String?) async throws -> Void
	public var unFollow: @Sendable (_ unFollowedId: String, _ unFollowerId: String?) async throws -> Void
	public var createPost: @Sendable (_ caption: String, _ mediaJsonString: String) async throws -> Post?
}

@DependencyClient
public struct SupabaseStorageUploaderClient: Sendable {
	public var uploadBinary: @Sendable (_ storageName: String, _ filePath: String, _ fileData: Data, _ fileOptions: FileOptions) async throws -> FileUploadResponse
}
