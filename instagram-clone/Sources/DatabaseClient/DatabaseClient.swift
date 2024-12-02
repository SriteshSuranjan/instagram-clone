import Foundation
import Shared

public protocol UserBaseRepository: Sendable {
	var currentUserId: String? { get async }
	func profile(of userId: String) async -> AsyncStream<User>
	func followersCount(of userId: String) async -> AsyncStream<Int>
	func followingsCount(of userId: String) async -> AsyncStream<Int>
	func followingStatus(of userId: String, followerId: String?) async -> AsyncStream<Bool>
	func isFollowed(followerId: String, userId: String) async throws -> Bool
	func follow(followedToId: String, followerId: String?) async throws -> Void
	func unFollow(unFollowedId: String, unFollowerId: String?) async throws -> Void
}

public protocol PostsBaseRepository: Sendable {
	func postsAmount(of userId: String) async -> AsyncStream<Int>
}

public protocol DatabaseClient: UserBaseRepository, PostsBaseRepository {}
