import AuthenticationClient
import DatabaseClient
import DependenciesMacros
import Foundation
import Shared
import Supabase

@DependencyClient
public struct InstagramClient: Sendable {
	public let authClient: UserAuthClient
	public let databaseClient: UserDatabaseClient
	public let storageUploaderClient: SupabaseStorageUploaderClient
	public let firebaseRemoteConfigClient: FirebaseRemoteConfigClient
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
	public var currentUserId: @Sendable () async -> String = { "" }
	public var updateUser: @Sendable (_ fullName: String?, _ username: String?, _ avatarUrl: String?, _ pushToken: String?) async throws -> Void
	public var isOwner: @Sendable (_ userId: String) async -> Bool = { _ in false }
	public var profile: @Sendable (_ userId: String) async -> AsyncStream<Shared.User> = { _ in .never }
	public var postsCount: @Sendable (_ userId: String) async -> AsyncStream<Int> = { _ in .never }
	public var followersCount: @Sendable (_ userId: String) async -> AsyncStream<Int> = { _ in .never }
	public var followingsCount: @Sendable (_ userId: String) async -> AsyncStream<Int> = { _ in .never }
	public var followingStatus: @Sendable (_ userId: String, _ followerId: String) async -> AsyncStream<Bool> = { _, _ in .never }
	public var isFollowed: @Sendable (_ followerId: String, _ userId: String) async throws -> Bool
	public var follow: @Sendable (_ followedToId: String, _ followerId: String?) async throws -> Void
	public var unFollow: @Sendable (_ unFollowedId: String, _ unFollowerId: String?) async throws -> Void
	public var followers: @Sendable (_ userId: String) async -> AsyncStream<[Shared.User]> = { _ in .never }
	public var followings: @Sendable (_ userId: String) async throws -> [Shared.User]
	public var removeFollower: @Sendable (_ followerId: String) async throws -> Void
	public var createPost: @Sendable (_ caption: String, _ mediaJsonString: String) async throws -> Post?
	public var getPost: @Sendable (_ offset: Int, _ limit: Int, _ onlyReels: Bool) async throws -> [Post]
	public var getPostLikersInFollowings: @Sendable (_ postId: String, _ offset: Int, _ limit: Int) async throws -> [Shared.User]
	public var likesOfPost: @Sendable (_ postId: String, _ post: Bool) async -> AsyncStream<Int> = { _, _ in .never }
	public var postCommentsCount: @Sendable (_ postId: String) async -> AsyncStream<Int> = { _ in .never }
	public var isLiked: @Sendable (_ postId: String, _ userId: String?, _ post: Bool) async -> AsyncStream<Bool> = { _, _, _ in .never }
	public var postAuthorFollowingStatus: @Sendable (_ postAuthorId: String, _ userId: String?) async -> AsyncStream<Bool> = { _, _ in .never }
	public var likePost: @Sendable (_ postId: String, _ post: Bool) async throws -> Void
	public var deletePost: @Sendable (_ postId: String) async throws -> Void
	public var updatePost: @Sendable (_ postId: String, _ caption: String) async throws -> Post?
}

@DependencyClient
public struct SupabaseStorageUploaderClient: Sendable {
	public var uploadBinaryWithFilePath: @Sendable (_ storageName: String, _ filePath: String, _ fileOptions: FileOptions) async throws -> FileUploadResponse
	public var uploadBinaryWithData: @Sendable (_ storageName: String, _ filePath: String, _ fileData: Data, _ fileOptions: FileOptions) async throws -> FileUploadResponse
	public var uploadToSignedURL: @Sendable (_ storageName: String, _ path: String, _ token: String, _ data: Data) async throws -> SignedURLUploadResponse
	public var getPublicUrl: @Sendable (_ storageName: String, _ path: String) async throws -> String?
	public var createSignedUrl: @Sendable (_ storageName: String, _ path: String) async throws -> String
}

@DependencyClient
public struct FirebaseRemoteConfigClient: Sendable {
	public var config: @Sendable () async throws -> Void
	public var fetchRemoteData: @Sendable (_ key: String) async throws -> String
}

