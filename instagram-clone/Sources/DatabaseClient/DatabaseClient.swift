import Foundation
import Shared

public protocol UserBaseRepository: Sendable {
	var currentUserId: String? { get async }
	func profile(of userId: String) async -> AsyncStream<User>
	func followersCount(of userId: String) async -> AsyncStream<Int>
	func followingsCount(of userId: String) async -> AsyncStream<Int>
	func isFollowed(followerId: String, userId: String) async throws -> Bool
	func follow(followedToId: String, followerId: String?) async throws -> Void
	func unFollow(unFollowedId: String, unFollowerId: String?) async throws -> Void
	func followers(of userId: String) async -> AsyncStream<[Shared.User]>
	func followings(of userId: String) async throws -> [Shared.User]
	func followingStatus(of userId: String, followerId: String) async -> AsyncStream<Bool>
	func removeFollower(of userId: String) async throws -> Void
}

public protocol PostsBaseRepository: Sendable {
	func postsAmount(of userId: String) async -> AsyncStream<Int>
	func createPost(postId: String, caption: String, mediaJsonString: String) async throws -> Post?
}

public protocol DatabaseClient: UserBaseRepository, PostsBaseRepository {}
