import Foundation
import Dependencies
import Supabase
import AuthenticationClient
import Shared
import PowerSyncRepository
import DatabaseClient

extension UserClient: DependencyKey {
	public static let liveValue = UserClient(
		authClient: unimplemented("Use static live Implementation Inject please. ", placeholder: .liveValue),
		databaseClient: unimplemented("Use static live Implementation Inject please. ", placeholder: .liveValue),
		storageUploaderClient: unimplemented("Use static live Implementation Inject please. ", placeholder: .liveValue)
	)
	public static func liveUserClient(
		authClient: AuthenticationClient,
		databaseClient: DatabaseClient,
		powerSyncRepository: PowerSyncRepository
	) -> UserClient {
		UserClient(
			authClient: UserAuthClient.liveSupabaseAuthenticationClient(
				authClient
			),
			databaseClient: UserDatabaseClient.livePowerSyncDatabaseClient(
				databaseClient
			),
			storageUploaderClient: SupabaseStorageUploaderClient.liveSupabaseStorageUploaderClient(
				powerSyncRepository
			)
		)
	}
}

extension UserAuthClient: DependencyKey {
	public static let liveValue = UserAuthClient(
		user: unimplemented("Use AuthenticationClient Implementation Inject please.", placeholder: .never),
		logInWithGoogle: unimplemented("Use AuthenticationClient Implementation Inject please."),
		logInWithGithub: unimplemented("Use AuthenticationClient Implementation Inject please."),
		logInWithPassword: unimplemented("Use AuthenticationClient Implementation Inject please."),
		signUpWithPassword: unimplemented("Use AuthenticationClient Implementation Inject please."),
		sendPasswordResetEmail: unimplemented("Use AuthenticationClient Implementation Inject please."),
		resetPassword: unimplemented("Use AuthenticationClient Implementation Inject please."),
		logOut: unimplemented("Use AuthenticationClient Implementation Inject please.")
	)
	public static func liveSupabaseAuthenticationClient(
		_ client: AuthenticationClient
	) -> UserAuthClient {
		UserAuthClient(
			user: {
				client.user
					.map { Shared.User.fromAuthenticationUser($0) }
					.eraseToStream()
			},
			logInWithGoogle: {
				try await client.logInWithGoogle()
			},
			logInWithGithub: {
				try await client.logInWithGithub()
			},
			logInWithPassword: { password, email, phone in
				try await client.logInWithPassword(password, email: email, phone: phone)
			},
			signUpWithPassword: { password, fullName, username, avatarUrl, email, phone, pushToken in
				try await client.signUpWithPassword(password, fullName: fullName, userName: username, avatarUrl: avatarUrl, email: email, phone: phone, pushToken: pushToken)
			},
			sendPasswordResetEmail: { email, redirectTo in
				try await client.sendPasswordResetEmail(email, redirectTo: redirectTo)
			},
			resetPassword: { token, email, newPassword in
				try await client.resetPassword(token: token, email: email, newPassword: newPassword)
			},
			logOut: {
				try await client.logOut()
			}
		)
	}
}

extension UserDatabaseClient: DependencyKey {
	public static let liveValue = UserDatabaseClient(
		currentUserId: unimplemented("Use live implementation please.", placeholder: ""),
		updateUser: unimplemented("Use live implementation please."),
		isOwner: unimplemented("Use live implementation please.", placeholder: false),
		profile: unimplemented("Use live implementation please.", placeholder: .never),
		postsCount: unimplemented("Use live implementation please.", placeholder: .never),
		followersCount: unimplemented("Use live implementation please.", placeholder: .never),
		followingsCount: unimplemented("Use live implementation please.", placeholder: .never),
		followingStatus: unimplemented("Use live implementation please.", placeholder: .never),
		isFollowed: unimplemented("Use live implementation please.", placeholder: false),
		follow: unimplemented("Use live implementation please."),
		unFollow: unimplemented("Use live implementation please."),
		followers: unimplemented("Use live implementation please.", placeholder: .never),
		followings: unimplemented("Use live implementation please."),
		removeFollower: unimplemented("Use live implementation please."),
		createPost: unimplemented("Use live implementation please.")
	)
	public static func livePowerSyncDatabaseClient(
		_ client: DatabaseClient
	) -> UserDatabaseClient {
		UserDatabaseClient(
			currentUserId: { await client.currentUserId!.lowercased() },
			updateUser: { fullName, username, avatarUrl, pushToken in
				try await client.updateUser(email: nil, avatarUrl: avatarUrl, username: username, fullName: fullName, pushToken: pushToken)
			},
			isOwner: { userId in
				await userId == client.currentUserId
			},
			profile: { userId in
				await client.profile(of: userId)
			},
			postsCount: { userId in
				await client.postsAmount(of: userId)
			},
			followersCount: { userId in
				await client.followersCount(of: userId)
			},
			followingsCount: { userId  in
				await client.followingsCount(of: userId)
			},
			followingStatus: { userId, followerId in
				await client.followingStatus(of: userId, followerId: followerId)
			},
			isFollowed: { followerId, userId in
				try await client.isFollowed(followerId: followerId, userId: userId)
			},
			follow: { followedToId, followerId in
				try await client.follow(followedToId: followedToId, followerId: followerId)
			},
			unFollow: { unFollowedId, unFollowerId in
				try await client.unFollow(unFollowedId: unFollowedId, unFollowerId: unFollowerId)
			},
			followers: { userId in
				await client.followers(of: userId)
			},
			followings: { userId in
				try await client.followings(of: userId)
			},
			removeFollower: { followerId in
				try await client.removeFollower(of: followerId)
			},
			createPost: { caption, mediaJsonString in
				@Dependency(\.uuid) var uuid
				let post = try await client.createPost(postId: uuid().uuidString.lowercased(), caption: caption, mediaJsonString: mediaJsonString)
				debugPrint("\(post) \(#line)")
				return post
			}
		)
	}
}

extension SupabaseStorageUploaderClient: DependencyKey {
	public static let liveValue = SupabaseStorageUploaderClient(
		uploadBinaryWithFilePath: unimplemented("Use live implementation please."),
		uploadBinaryWithData: unimplemented("Use live implementation please."),
		uploadToSignedURL: unimplemented("Use live implementation please."),
		getPublicUrl: unimplemented("Use live implementation please."),
		createSignedUrl: unimplemented("Use live implementation please.")
	)
	public static func liveSupabaseStorageUploaderClient(_ powerSyncReository: PowerSyncRepository) -> SupabaseStorageUploaderClient {
		SupabaseStorageUploaderClient(
			uploadBinaryWithFilePath: { storageName, filePath, fileOptions in
				try await powerSyncReository.supabase.storage.from(storageName)
					.upload(filePath, fileURL: URL(string: filePath)!)
			},
			uploadBinaryWithData: { storageName, filePath, fileData, fileOptions in
				try await powerSyncReository.supabase.storage.from(storageName)
					.upload(filePath, data: fileData, options: fileOptions)
			},
			uploadToSignedURL: { storageName, path, token, data in
				try await powerSyncReository.supabase.storage.from(storageName).uploadToSignedURL(path, token: token, data: data)
			},
			getPublicUrl: { storageName, path in
				try await powerSyncReository.supabase.storage.from(storageName).getPublicURL(path: path, download: false).absoluteString
			},
			createSignedUrl: { storageName, path in
//				try await powerSyncReository.supabase.storage.from(storageName).createSignedUploadURL(path: path)
				try await powerSyncReository.supabase.storage.from(storageName).createSignedURL(path: path, expiresIn: 60).absoluteString
			}
		)
	}
}
