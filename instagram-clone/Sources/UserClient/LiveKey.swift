import Foundation
import Dependencies
import Supabase
import AuthenticationClient
import Shared
import PowerSyncRepository

extension UserClient: DependencyKey {
	public static let liveValue = UserClient(
		user: unimplemented("Use AuthenticationClient Implementation Inject please.", placeholder: .never),
//		authStateChanges: unimplemented("Use AuthenticationClient Implementation Inject please.", placeholder: .never),
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
	) -> UserClient {
		UserClient(
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
