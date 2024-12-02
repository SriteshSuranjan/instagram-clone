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
		databaseClient: unimplemented("Use static live Implementation Inject please. ", placeholder: .liveValue)
	)
	public static func liveUserClient(
		authClient: AuthenticationClient,
		databaseClient: DatabaseClient
	) -> UserClient {
		UserClient(
			authClient: UserAuthClient.liveSupabaseAuthenticationClient(
				authClient
			),
			databaseClient: UserDatabaseClient.livePowerSyncDatabaseClient(
				databaseClient
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
		isOwner: unimplemented("Use live implementation please.", placeholder: false),
		profile: unimplemented("Use live implementation please.", placeholder: .never)
	)
	public static func livePowerSyncDatabaseClient(
		_ client: DatabaseClient
	) -> UserDatabaseClient {
		UserDatabaseClient(
			currentUserId: { await client.currentUserId },
			isOwner: { userId in
				await userId == client.currentUserId
			},
			profile: { userId in
				await client.profile(of: userId)
			}
		)
	}
}
