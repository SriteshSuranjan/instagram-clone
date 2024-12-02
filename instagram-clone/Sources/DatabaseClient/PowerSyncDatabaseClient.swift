import Foundation
import PowerSync
import PowerSyncRepository
import Shared

public actor PowerSyncDatabaseClient: DatabaseClient {
	public let powerSyncRepository: PowerSyncRepository
	public init(powerSyncRepository: PowerSyncRepository) {
		self.powerSyncRepository = powerSyncRepository
	}

	public var currentUserId: String? {
		get async {
			try? await powerSyncRepository.supabase.auth.session.user.id.uuidString
		}
	}

	// MARK: - UserBaseRepository

	public func profile(of userId: String) async -> AsyncStream<User> {
		AsyncStream { continuation in
			Task {
				for await data in await powerSyncRepository.db.watch(
					sql: "SELECT * FROM profiles WHERE id = ?",
					parameters: [userId],
					mapper: { cursor in
						guard let id = cursor.getString(index: 0) else {
							return User.anonymous
						}
						let fullName = cursor.getString(index: 1)
						let email = cursor.getString(index: 2)
						let userName = cursor.getString(index: 3)
						let avatarUrl = cursor.getString(index: 4)
						let pushToken = cursor.getString(index: 5)
						return User(
							id: id,
							email: email,
							username: userName,
							fullName: fullName,
							avatarUrl: avatarUrl,
							pushToken: pushToken,
							isNewUser: false
						)
					}
				) {
					if let user = (data as? [User])?.first {
						continuation.yield(user)
					} else {
						debugPrint(data)
					}
				}
				continuation.finish()
			}
		}
	}
	
	public func followersCount(of userId: String) async -> AsyncStream<Int> {
		AsyncStream { continuation in
			Task {
				for await data in await powerSyncRepository.db.watch(
					sql: "SELECT COUNT(*) AS subscription_count FROM subscriptions WHERE subscribed_to_id = ?",
					parameters: [userId],
					mapper: { cursor in
						cursor.getLong(index: 0) ?? 0
					}
				) {
					if let subscriptionsCount = (data as? [Int])?.first {
						continuation.yield(subscriptionsCount)
					} else {
						debugPrint(data)
					}
				}
				continuation.finish()
			}
		}
	}
	
	public func followingsCount(of userId: String) async -> AsyncStream<Int> {
		AsyncStream { continuation in
			Task {
				for await data in await powerSyncRepository.db.watch(
					sql: "SELECT COUNT(*) AS subscription_count FROM subscriptions WHERE subscriber_id = ?",
					parameters: [userId],
					mapper: { cursor in
						cursor.getLong(index: 0) ?? 0
					}
				) {
					if let subscriptionsCount = (data as? [Int])?.first {
						continuation.yield(subscriptionsCount)
					} else {
						debugPrint(data)
					}
				}
				continuation.finish()
			}
		}
	}
	
	public func followingStatus(of userId: String, followerId: String?) async -> AsyncStream<Bool> {
		AsyncStream { continuation in
			Task {
				let currentUserId = await currentUserId
				if followerId == nil && currentUserId == nil {
					continuation.finish()
					return
				}
				for await data in await powerSyncRepository.db.watch(
					sql: "SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?",
					parameters: [followerId ?? currentUserId!, userId],
					mapper: { _ in
						true
					}
				) {
					continuation.yield(!data.isEmpty)
				}
				continuation.finish()
			}
		}
	}
	
	public func isFollowed(followerId: String, userId: String) async throws -> Bool {
		let result = try await powerSyncRepository.db.execute(
			sql: "SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?",
			parameters: [followerId, userId]
		)
		debugPrint(result)
		return false
	}
	
	public func follow(followedToId: String, followerId: String?) async throws {
		guard let currentUserId = await currentUserId else {
			return
		}
		guard followedToId != currentUserId else {
			return
		}
		let exists = try await isFollowed(followerId: followerId ?? currentUserId, userId: followedToId)
		if !exists {
			try await powerSyncRepository.db.execute(
				sql: "INSERT INTO subscriptions(id, subscriber_id, subscribed_to_id) VALUES (uuid(), ?, ?)",
				parameters: [followerId ?? currentUserId, followedToId]
			)
		} else {
			try await unFollow(unFollowedId: followedToId, unFollowerId: followerId)
		}
	}
	
	public func unFollow(unFollowedId: String, unFollowerId: String?) async throws {
		guard let currentUserId = await currentUserId else {
			return
		}
		try await powerSyncRepository.db.execute(
			sql: "DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?",
			parameters: [unFollowerId ?? currentUserId, unFollowedId]
		)
	}

	// MARK: - PostsBaseRepository

	public func postsAmount(of userId: String) async -> AsyncStream<Int> {
		AsyncStream { continuation in
			Task {
				for await data in await powerSyncRepository.db.watch(
					sql: "SELECT COUNT(*) AS posts_count FROM posts WHERE user_id = ?",
					parameters: [userId],
					mapper: { cursor in
						cursor.getLong(index: 0) ?? 0
					}
				) {
					if let postsCount = (data as? [Int])?.first {
						continuation.yield(postsCount)
					} else {
						debugPrint(data)
					}
				}
				continuation.finish()
			}
		}
	}
}
