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
					parameters: [userId.lowercased()],
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

	public func isFollowed(followerId: String, userId: String) async throws -> Bool {
		let result = try await powerSyncRepository.db.get(
			sql: "SELECT COUNT(*) FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?",
			parameters: [followerId.lowercased(), userId],
			mapper: { cursor in
				cursor.getLong(index: 0) ?? 0
			}
		)
		guard let count = result as? Int else {
			return false
		}
		return count > 0
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
		guard let currentUserId = await currentUserId?.lowercased() else {
			return
		}
		try await powerSyncRepository.db.execute(
			sql: "DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?",
			parameters: [unFollowerId ?? currentUserId, unFollowedId]
		)
	}

	public func followers(of userId: String) async -> AsyncStream<[Shared.User]> {
		AsyncStream { continuation in
			Task {
				for await data in await powerSyncRepository.db.watch(
					sql: "SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ?",
					parameters: [userId.lowercased()],
					mapper: { cursor in
						cursor.getString(index: 0) ?? ""
					}
				) {
					guard let followerIds = data as? [String] else {
						return
					}
					var followers: [Shared.User] = []
					for followerId in followerIds {
						let follower = try await self.powerSyncRepository.db.get(
							sql: "SELECT * FROM profiles WHERE id = ?",
							parameters: [followerId.lowercased()],
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
						followers.append(follower as! Shared.User)
					}
					continuation.yield(followers)
				}
				continuation.finish()
			}
		}
	}

	public func followings(of userId: String) async throws -> [Shared.User] {
		try (
			await powerSyncRepository.db.readTransaction(
				callback: SuspendTaskWrapper<[Shared.User]> { _ in
					let followingIds = try await self.powerSyncRepository.db.getAll(
						sql: "SELECT subscribed_to_id FROM subscriptions WHERE subscriber_id = ?",
						parameters: [userId.lowercased()],
						mapper: { cursor in
							cursor.getString(index: 0) ?? ""
						}
					)
					var followings: [Shared.User] = []
					for followingId in followingIds as? [String] ?? [] {
						let user = try await self.powerSyncRepository.db.get(
							sql: "SELECT * FROM profiles WHERE id = ?",
							parameters: [followingId.lowercased()],
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
						followings.append(user as! Shared.User)
					}
					return followings
				}) as? [Shared.User]
		) ?? []
	}

	public func followingStatus(of userId: String, followerId: String) async -> AsyncStream<Bool> {
		AsyncStream { continuation in
			Task {
				for await followed in await self.powerSyncRepository.db.watch(
					sql: "SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?",
					parameters: [followerId.lowercased(), userId.lowercased()],
					mapper: { cursor in
						cursor.getString(index: 0) ?? ""
					}
				) {
					continuation.yield(!followed.isEmpty)
				}
				continuation.finish()
			}
		}
	}

	public func removeFollower(of userId: String) async throws {
		guard let currentUserId = await currentUserId else {
			return
		}
		try await powerSyncRepository.db.execute(
			sql: "DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?",
			parameters: [userId, currentUserId.lowercased()]
		)
	}

	public func updateUser(
		email: String? = nil,
		avatarUrl: String? = nil,
		username: String? = nil,
		fullName: String? = nil,
		pushToken: String? = nil
	) async throws {
		var data: [String: AnyJSON] = [:]
		if let username {
			data["username"] = .string(username)
		}
		if let fullName {
			data["full_name"] = .string(fullName)
		}
		if let avatarUrl {
			data["avatar_url"] = .string(avatarUrl)
		}
		if let pushToken {
			data["push_token"] = .string(pushToken)
		}
		try await powerSyncRepository.updateUser(data: data)
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
					Date.now.ISO8601Format(.iso8601)
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

	public func getPage(
		offset: Int,
		limit: Int,
		onlyReels: Bool = false
	) async throws -> [Post] {
		let value = try await powerSyncRepository.db.getAll(
			sql:
			"""
				 SELECT 
					posts.*,
					p.id as user_id,
					p.avatar_url as avatar_url,
					p.username as username,
					p.full_name as full_name
				 FROM
					posts
					inner join profiles p on posts.user_id = p.id
					ORDER BY created_at DESC LIMIT ? OFFSET ?
			""",
			parameters: [
				limit, offset
			],
			mapper: { cursor in
				let postId = cursor.getString(index: 0) ?? ""
				let authorId = cursor.getString(index: 1) ?? ""
				let createdAt = cursor.getString(index: 2) ?? ""
				let caption = cursor.getString(index: 3) ?? ""
				let mediaJsonString = cursor.getString(index: 5) ?? ""
//				let userId = cursor.getString(index: 6) ?? ""
				let avatarUrl = cursor.getString(index: 7)
				let userName = cursor.getString(index: 8)
				let fullName = cursor.getString(index: 9)
				return Post(id: postId, author: User(id: authorId, username: userName, fullName: fullName, avatarUrl: avatarUrl), caption: caption, createdAt: try! Date(createdAt, strategy: .dateTime), media: (try? PowerSyncRepository.decoder.decode([MediaItem].self, from: mediaJsonString.data(using: .utf8)!)) ?? [])
			}
		)
		guard let posts = value as? [Post] else {
			return []
		}
		if onlyReels {
			return posts.filter { $0.media.count == 1 && $0.media[0].isVideo }
		} else {
			return posts
		}
	}

	public func getPostLikersInFollowings(postId: String, offset: Int = 0, limit: Int = 3) async throws -> [Shared.User] {
		guard let currentUserId = await currentUserId else {
			return []
		}
		return try await powerSyncRepository.db.getAll(
			sql: """
			SELECT id, avatar_url, username, full_name
			FROM profiles
			WHERE id IN (
					SELECT l.user_id
					FROM likes l
					WHERE l.post_id = ?
					AND EXISTS (
							SELECT *
							FROM subscriptions f
							WHERE f.subscribed_to_id = l.user_Id
							AND f.subscriber_id = ?
					) AND id <> ?
			)
			LIMIT ? OFFSET ?
			""",
			parameters: [postId, currentUserId.lowercased(), limit, offset],
			mapper: { cursor in
				let userId = cursor.getString(index: 0) ?? ""
				let avatarUrl = cursor.getString(index: 1)
				let username = cursor.getString(index: 2)
				let fullName = cursor.getString(index: 3)
				return User(id: userId, username: username, fullName: fullName, avatarUrl: avatarUrl)
			}
		) as? [Shared.User] ?? []
	}

	public func likesOfPost(postId: String, post: Bool = true) async -> AsyncStream<Int> {
		let statement = post ? "post_id" : "comment_id"
		return AsyncStream { continuation in
			Task {
				for await data in await powerSyncRepository.db.watch(
					sql: """
					SELECT COUNT(*)
					FROM likes
					WHERE \(statement) = ? AND \(statement) IS NOT NULL
					""",
					parameters: [postId],
					mapper: { cursor in
						cursor.getLong(index: 0) ?? 0
					}
				) {
					continuation.yield((data as? [Int] ?? []).first ?? 0)
				}
				continuation.finish()
			}
		}
	}

	public func postCommentsCount(postId: String) async -> AsyncStream<Int> {
		AsyncStream { continuation in
			Task {
				for await data in await powerSyncRepository.db.watch(
					sql: "SELECT COUNT(*) FROM comments WHERE post_id = ?",
					parameters: [postId],
					mapper: { cursor in
						cursor.getLong(index: 0) ?? 0
					}
				) {
					continuation.yield((data as? [Int])?.first ?? 0)
				}
				continuation.finish()
			}
		}
	}

	public func isLiked(postId: String, userId: String?, post: Bool = true) async -> AsyncStream<Bool> {
		guard let currentUserId = await currentUserId else {
			return .finished
		}
		let statement = post ? "post_id" : "comment_id"
		return AsyncStream { continuation in
			Task {
				for await data in await powerSyncRepository.db.watch(
					sql: "SELECT EXISTS(SELECT 1 FROM likes WHERE user_id = ? AND \(statement) = ? AND \(statement) IS NOT NULL)",
					parameters: [currentUserId.lowercased(), postId],
					mapper: { cursor in
						cursor.getLong(index: 0) ?? 0
					}
				) {
					if let result = data as? [Int] {
						continuation.yield((result.first ?? 0) > 0)
					} else {
						continuation.yield(false)
					}
				}
				continuation.finish()
			}
		}
	}

	public func postAuthorFollowingStatus(postAuthorId: String, userId: String? = nil) async -> AsyncStream<Bool> {
		guard let currentUserId = await currentUserId else {
			return .finished
		}
		return await followingStatus(of: postAuthorId, followerId: userId ?? currentUserId)
	}

	public func likePost(postId: String, post: Bool = true) async throws {
		guard let currentUserId = await currentUserId else {
			return
		}
		let statement = post ? "post_id" : "comment_id"
		let exists = try (await powerSyncRepository.db.get(
			sql: "SELECT EXISTS(SELECT 1 FROM likes WHERE user_id = ? AND \(statement) = ? AND \(statement) IS NOT NULL)",
			parameters: [currentUserId.lowercased(), postId],
			mapper: { cursor in
				cursor.getLong(index: 0) ?? 0
			}
		) as? Int ?? 0) > 0
		if !exists {
			try await powerSyncRepository.db.execute(
				sql: "INSERT INTO likes (user_id, \(statement), id) VALUES (?, ?, uuid())",
				parameters: [currentUserId.lowercased(), postId]
			)
		} else {
			try await powerSyncRepository.db.execute(
				sql: "DELETE FROM likes WHERE user_id = ? AND \(statement) = ? AND \(statement) IS NOT NULL",
				parameters: [currentUserId.lowercased(), postId]
			)
		}
	}

	public func deletePost(postId: String) async throws {
		try await powerSyncRepository.db.execute(
			sql: "DELETE FROM posts WHERE id = ?",
			parameters: [postId]
		)
	}

	public func updatePost(postId: String, caption: String) async throws -> Post? {
		guard let currentUserId = await currentUserId else {
			return nil
		}
		return try await powerSyncRepository.db.writeTransaction(callback: SuspendTaskWrapper<Post?> { _ in
			try await self.powerSyncRepository.db.execute(
				sql: """
				UPDATE posts
				SET
					caption = ?,
					updated_at = ?
				WHERE id = ?
				""",
				parameters: [caption, Date.now.ISO8601Format(.iso8601), postId]
			)
			let postData = try await self.powerSyncRepository.db.get(
				sql: "SELECT id, user_id, caption, media, created_at, updated_at FROM posts WHERE id = ?",
				parameters: [postId],
				mapper: { cursor in
					guard let id = cursor.getString(index: 0),
					      let userId = cursor.getString(index: 1),
					      let caption = cursor.getString(index: 2),
					      let mediaJson = cursor.getString(index: 3),
					      let createdAt = cursor.getString(index: 4),
					      let updatedAt = cursor.getString(index: 5)
					else {
						return ("", "", "", "", "", "")
					}
					return (id, userId, caption, mediaJson, createdAt, updatedAt)
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

			guard let postTuple = postData as? (String, String, String, String, String, String),
			      let user = author as? Shared.User,
			      let createdAt = try? Date(postTuple.4, strategy: .dateTime),
			      let updatedAt = try? Date(postTuple.5, strategy: .iso8601),
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
				updatedAt: updatedAt,
				media: mediaItems
			)
			return post
		}) as? Post
	}

	public func postsOf(userId: String?) async -> AsyncStream<[Post]> {
		AsyncStream { continuation in
			Task {
				guard let currentUserId = await currentUserId else {
					continuation.finish()
					return
				}
				for await data in await self.powerSyncRepository.db.watch(
					sql: """
					SELECT 
					  posts.*,
					  p.avatar_url as avatar_url,
					  p.username as username,
					  p.full_name as full_name
					FROM 
					  posts
					  left join profiles p on posts.user_id = p.id
					WHERE user_id = ?
					ORDER BY created_at DESC
					""",
					parameters: [userId ?? currentUserId],
					mapper: { cursor -> Post in
						let postId = cursor.getString(index: 0)
						let userId = cursor.getString(index: 1)
						let createdAt = cursor.getString(index: 2)
						let caption = cursor.getString(index: 3)
						let updatedAt = cursor.getString(index: 4)
						let mediaJson = cursor.getString(index: 5)
						let avatarUrl = cursor.getString(index: 6)
						let username = cursor.getString(index: 7)
						let fullName = cursor.getString(index: 8)
						return Post(
							id: postId ?? "",
							author: Shared.User(id: userId ?? "", username: username, fullName: fullName, avatarUrl: avatarUrl),
							caption: caption ?? "",
							createdAt: (try? Date(createdAt ?? "", strategy: .dateTime)) ?? .now,
							updatedAt: try? Date(updatedAt ?? "", strategy: .dateTime),
							media: (try? PowerSyncRepository.decoder.decode([MediaItem].self, from: (mediaJson ?? "").data(using: .utf8)!)) ?? []
						)
					}
				) {
					if let posts = data as? [Post] {
						continuation.yield(posts)
					} else {
						continuation.yield([])
					}
				}
				continuation.finish()
			}
		}
	}

	public func searchUsers(
		limit: Int = 8,
		offset: Int = 0,
		query: String,
		userId: String? = nil,
		excludedUserIds: [String] = []
	) async throws -> [Shared.User] {
		guard let currentUserId = await currentUserId else {
			return []
		}
		guard !query.isEmpty else {
			return []
		}
		let excludeUserIdsStatement = excludedUserIds.isEmpty ? "" : "AND id NOT IN (\(excludedUserIds)"
		return try (await powerSyncRepository.db.getAll(
			sql: """
			SELECT id, avatar_url, full_name, username
			FROM profiles
			WHERE (LOWER(username) LIKE LOWER('%\(query)%') OR LOWER(full_name) LIKE LOWER('%\(query)%')) AND id <> ?1 \(excludeUserIdsStatement)
			LIMIT ?2 OFFSET ?3
			""",
			parameters: [currentUserId, limit, offset],
			mapper: { cursor in
				let userId = cursor.getString(index: 0) ?? ""
				let avatarUrl = cursor.getString(index: 1)
				let full_name = cursor.getString(index: 2)
				let username = cursor.getString(index: 3)
				return Shared.User(id: userId, username: username, fullName: full_name, avatarUrl: avatarUrl)
			}
		) as? [Shared.User]) ?? []
	}

	public func commentsOf(postId: String) async -> AsyncStream<[Comment]> {
		AsyncStream { continuation in
			Task {
				for await data in await self.powerSyncRepository.db.watch(
					sql: """
					SELECT 
						c1.*,
						p.avatar_url as avatar_url,
						p.username as username,
						p.full_name as full_name,
						COUNT(c2.id) AS replies
					FROM 
						comments c1
						INNER JOIN
							profiles p ON p.id = c1.user_id
						LEFT JOIN
							comments c2 ON c1.id = c2.replied_to_comment_id
					WHERE
						c1.post_id = ? AND c1.replied_to_comment_id IS NULL
					GROUP BY
						c1.id, p.avatar_url, p.username, p.full_name
					ORDER BY created_at ASC
					""",
					parameters: [postId],
					mapper: { cursor in
						let commentId = cursor.getString(index: 0) ?? ""
						let postId = cursor.getString(index: 1) ?? ""
						let commentAuthorId = cursor.getString(index: 2) ?? ""
						let content = cursor.getString(index: 3) ?? ""
						let createdAt = (try? Date(cursor.getString(index: 4) ?? "", strategy: .dateTime)) ?? Date.now
						let avatarUrl = cursor.getString(index: 6)
						let username = cursor.getString(index: 7)
						let repliesCount = cursor.getLong(index: 9)?.intValue
						let comment = Shared.Comment(
							id: commentId,
							postId: postId,
							author: PostAuthor(confirmed: commentAuthorId, avatarUrl: avatarUrl, username: username),
							repliedToCommentId: nil,
							replies: repliesCount,
							content: content,
							createdAt: createdAt
						)
						return comment
					}
				) {
					if let comments = data as? [Comment] {
						continuation.yield(comments)
					}
				}
				continuation.finish()
			}
		}
	}

	public func createComment(postId: String, userId: String, content: String, repliedToCommentId: String?) async throws {
		try await powerSyncRepository.db.execute(
			sql: """
			INSERT INTO 
				comments(id, post_id, user_id, content, created_at, replied_to_comment_id)
			VALUES(uuid(), ?, ?, ?, ?, ?)
			""",
			parameters: [postId, userId, content, Date.now.ISO8601Format(.iso8601), repliedToCommentId as Any]
		)
	}

	public func repliedCommentsOf(commentId: String) async -> AsyncStream<[Comment]> {
		AsyncStream { continuation in
			Task {
				for await data in await self.powerSyncRepository.db.watch(
					sql: """
					SELECT 
						c1.*,
						p.avatar_url as avatar_url,
						p.username as username,
						p.full_name as full_name
					FROM 
						comments c1
						INNER JOIN
							profiles p ON p.id = c1.user_id
					WHERE
						c1.replied_to_comment_id = ?
					GROUP BY
						c1.id, p.avatar_url, p.username, p.full_name
					ORDER BY created_at ASC
					""",
					parameters: [commentId],
					mapper: { cursor in
						let commentId = cursor.getString(index: 0) ?? ""
						let postId = cursor.getString(index: 1) ?? ""
						let commentAuthorId = cursor.getString(index: 2) ?? ""
						let content = cursor.getString(index: 3) ?? ""
						let createdAt = (try? Date(cursor.getString(index: 4) ?? "", strategy: .dateTime)) ?? Date.now
						let repliedCommentId = cursor.getString(index: 5)
						let avatarUrl = cursor.getString(index: 6)
						let username = cursor.getString(index: 7)
//						let fullName = cursor.getString(index: 8)
						return Comment(
							id: commentId,
							postId: postId,
							author: PostAuthor(confirmed: commentAuthorId, avatarUrl: avatarUrl, username: username),
							repliedToCommentId: repliedCommentId,
							replies: nil,
							content: content,
							createdAt: createdAt
						)
					}
				) {
					if let comments = data as? [Comment] {
						continuation.yield(comments)
					}
				}
				continuation.finish()
			}
		}
	}

	public func deleteComment(commentId: String) async throws {
		try await powerSyncRepository.db.execute(
			sql: "DELETE FROM comments WHERE id = ?",
			parameters: [commentId]
		)
	}

	public func chatsOf(userId: String) async -> AsyncStream<[ChatInbox]> {
		AsyncStream { continuation in
			Task {
				for await data in await self.powerSyncRepository.db.watch(
					sql: """
					select
						c.id,
						c.type,
						c.name,
						p2.id as participant_id,
						p2.full_name as participant_name,
						p2.email as participant_email,
						p2.username as participant_username,
						p2.avatar_url as participant_avatar_url,
						p2.push_token as participant_push_token
					from
						conversations c
						join participants pt on c.id = pt.conversation_id
						join profiles p on pt.user_id = p.id
						join participants pt2 on c.id = pt2.conversation_id
						join profiles p2 on pt2.user_id = p2.id
					where
						pt.user_id = ?1
						and pt2.user_id != ?1
					""",
					parameters: [userId],
					mapper: { cursor in
						let chatId = cursor.getString(index: 0) ?? ""
						let type = cursor.getString(index: 1)
						let _ = cursor.getString(index: 2) ?? ""
						let participantId = cursor.getString(index: 3) ?? ""
						let participantName = cursor.getString(index: 4) ?? ""
						let participantEmail = cursor.getString(index: 5)
						let participantUsername = cursor.getString(index: 6)
						let participantAvatarUrl = cursor.getString(index: 7)
						let participantPushToken = cursor.getString(index: 8)
						return ChatInbox(
							id: chatId,
							type: type,
							unreadMessagesCount: 0,
							participant: Shared.User(
								id: participantId,
								email: participantEmail,
								username: participantUsername,
								fullName: participantName,
								avatarUrl: participantAvatarUrl,
								pushToken: participantPushToken,
								isNewUser: false
							)
						)
					}
				) {
					if let chats = data as? [ChatInbox] {
						continuation.yield(chats)
					}
				}
				continuation.finish()
			}
		}
	}

	public func deleteChat(chatId: String, userId: String) async throws {}

	public func createChat(userId: String, participantId: String) async throws {}

	public func messagesOf(chatId: String) async -> AsyncStream<[Shared.Message]> {
		AsyncStream { _ in }
	}

	public func sendMessage(
		chatId: String,
		sender: Shared.User,
		receiver: Shared.User,
		message: Shared.Message,
		postAuthor: PostAuthor?
	) async throws {}

	public func deleteMessage(messageId: String) async throws {}

	public func readMessage(messageId: String) async throws {}

	public func editMessage(oldMessage: Shared.Message, newMessage: Shared.Message) async throws {}
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
