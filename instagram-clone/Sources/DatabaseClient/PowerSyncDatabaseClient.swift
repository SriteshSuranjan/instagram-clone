import Foundation
import PowerSync
import PowerSyncRepository
import Shared
import Supabase

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

	public func profile(of userId: String) async -> AsyncStream<Shared.User> {
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
					if let user = (data as? [Shared.User])?.first {
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
				parameters: [(followerId ?? currentUserId).lowercased(), followedToId.lowercased()]
			)
		} else {
			try await unFollow(unFollowedId: followedToId.lowercased(), unFollowerId: followerId?.lowercased())
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
					parameters: [userId.lowercased()],
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

	public func createPost(postId: String, caption: String, mediaJsonString: String) async throws -> Post? {
		guard let currentUserId = await currentUserId else {
			return nil
		}
		return try await powerSyncRepository.db.writeTransaction(callback: SuspendTaskWrapper<Post?> { _ in
			try await self.powerSyncRepository.db.execute(
				sql: """
				INSERT INTO posts (id, user_id, caption, media, created_at)
				VALUES(?, ?, ?, ?, ?)
				""",
				parameters: [
					postId,
					currentUserId,
					caption,
					mediaJsonString,
					Date.now.ISO8601Format()
				]
			)

			let postData = try await self.powerSyncRepository.db.get(
				sql: "SELECT id, user_id, caption, media, created_at FROM posts WHERE id = ?",
				parameters: [postId],
				mapper: { cursor in
					guard let id = cursor.getString(index: 0),
					      let userId = cursor.getString(index: 1),
					      let caption = cursor.getString(index: 2),
					      let mediaJson = cursor.getString(index: 3),
					      let createdAt = cursor.getString(index: 4)
					else {
						return ("", "", "", "", "")
					}
					return (id, userId, caption, mediaJson, createdAt)
				}
			)

			let author = try await self.powerSyncRepository.db.get(
				sql: "SELECT * FROM profiles WHERE id = ?",
				parameters: [currentUserId.lowercased()],
				mapper: { cursor in
					guard let id = cursor.getString(index: 0) else {
						return Shared.User.anonymous
					}
					return Shared.User(
						id: id,
						email: cursor.getString(index: 2),
						username: cursor.getString(index: 3),
						fullName: cursor.getString(index: 1),
						avatarUrl: cursor.getString(index: 4),
						pushToken: cursor.getString(index: 5),
						isNewUser: false
					)
				}
			)

			guard let postTuple = postData as? (String, String, String, String, String),
			      let user = author as? Shared.User,
			      let createdAt = try? Date(postTuple.4, strategy: .iso8601),
			      let mediaData = postTuple.3.data(using: .utf8)
			else {
				return nil
			}
			let mediaItems = (try? PowerSyncRepository.decoder.decode([MediaItem].self, from: mediaData)) ?? []

			let post = Post(
				id: postTuple.0,
				author: user,
				caption: postTuple.2,
				createdAt: createdAt,
				media: mediaItems
			)
			return post
		}) as? Post
	}
}

private class SuspendTaskWrapper<T>: KotlinSuspendFunction1 {
	let handle: (Any?) async throws -> T

	init(_ handle: @escaping (Any?) async throws -> T) {
		self.handle = handle
	}

	func invoke(p1: Any?, completionHandler: @escaping (Any?, Error?) -> Void) {
		Task {
			do {
				let result = try await self.handle(p1)
				completionHandler(result, nil)
			} catch {
				completionHandler(nil, error)
			}
		}
	}
}
