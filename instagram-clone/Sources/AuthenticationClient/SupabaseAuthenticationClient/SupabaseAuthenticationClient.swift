import Foundation
@preconcurrency import GoogleSignIn
import PowerSyncRepository
import Shared
import Supabase

@MainActor
public final class SupabaseAuthenticationClient {
	public let powerSyncRepository: PowerSyncRepository
	let tokenStorage: TokenStorage
	let googleSignIn: GIDSignIn
	private var userChangeTask: Task<Void, Error>?
	deinit {
		userChangeTask?.cancel()
	}

	public init(powerSyncRepository: PowerSyncRepository, tokenStorage: TokenStorage, googleSignIn: GIDSignIn) {
		self.powerSyncRepository = powerSyncRepository
		self.tokenStorage = tokenStorage
		self.googleSignIn = googleSignIn
		startListening()
	}
	
	public func startListening() {
		// Ensure this method is called after initialization
		userChangeTask = Task { [weak self] in
			guard let self = self else { return }
			do {
				for await (_, session) in await self.powerSyncRepository.authState {
					let user = session?.user.toUser ?? .anonymous
					if user.isAnonymous {
						try await self.tokenStorage.saveToken(user.id)
					} else {
						try await self.tokenStorage.clearToken()
					}
				}
			} catch {
				print("Token operation failed: \(error)")
			}
		}
	}
}

extension SupabaseAuthenticationClient {
	private func getTopViewController() -> UIViewController? {
		let scenes = UIApplication.shared.connectedScenes
		let windowScene = scenes.first as? UIWindowScene
		let window = windowScene?.windows.first(where: { $0.isKeyWindow })
					
		var topController = window?.rootViewController
		while let presentedController = topController?.presentedViewController {
			topController = presentedController
		}
		return topController
	}
}

extension SupabaseAuthenticationClient: AuthenticationClient {
	public func logInWithPassword(_ password: String, email: String?, phone: String?) async throws {
		guard email != nil || phone != nil else {
			throw AuthenticatonError.logInWithPasswordCanceled(message: "You must provide either ann email or a phone number.")
		}
		if let email {
			try await powerSyncRepository.supabase.auth.signIn(email: email, password: password)
		} else if let phone {
			try await powerSyncRepository.supabase.auth.signIn(phone: phone, password: password)
		}
	}
	
	public func logInWithGoogle() async throws {
		guard let rootController = getTopViewController() else {
			throw AuthenticatonError.logInWithPasswordCanceled(message: "Root Controller not available")
		}
		let googleUser = try await googleSignIn.signIn(withPresenting: rootController).user
		let idToken = googleUser.idToken
		guard let idToken else {
			throw AuthenticatonError.logInWithGoogleFailure(message: "No ID Token found.")
		}
		try await powerSyncRepository.supabase.auth.signInWithIdToken(
			credentials: OpenIDConnectCredentials(
				provider: .google,
				idToken: idToken.tokenString
			)
		)
	}
	
	public func logInWithGithub() async throws {
		try await powerSyncRepository.supabase.auth.signInWithOAuth(
			provider: .github,
			redirectTo: URL(string: "com.lamberthyl.nativeapp://login-callback")
		)
	}
	
	public func signUpWithPassword(_ password: String, fullName: String, userName: String, avatarUrl: String?, email: String?, phone: String?, pushToken: String?) async throws {
		guard email != nil || phone != nil else {
			throw AuthenticatonError.logInWithPasswordCanceled(message: "You must provide either ann email or a phone number.")
		}
		var data: [String: AnyJSON] = [
			"full_name": .string(fullName),
			"username": .string(userName),
		]
		if let avatarUrl {
			data["avatar_url"] = .string(avatarUrl)
		}
		if let pushToken {
			data["push_token"] = .string(pushToken)
		}
		if let email {
			try await powerSyncRepository.supabase.auth.signUp(
				email: email,
				password: password,
				data: data,
				redirectTo: URL(string: "com.lamberthyl.nativeapp://login-callback")
			)
		} else if let phone {
			try await powerSyncRepository.supabase.auth.signUp(phone: phone, password: password)
		}
	}
	
	public func sendPasswordResetEmail(_ email: String, redirectTo: String?) async throws {
		try await powerSyncRepository.supabase.auth.resetPasswordForEmail(email, redirectTo: URL(string: redirectTo ?? ""))
	}
	
	public func resetPassword(token: String, email: String, newPassword: String) async throws {
		try await powerSyncRepository.supabase.auth.verifyOTP(email: email, token: token, type: .recovery)
		try await powerSyncRepository.updateUser(password: newPassword)
	}
	
	public func logOut() async throws {
		try await powerSyncRepository.db.wrappedValue.disconnectAndClear(clearLocal: true)
		try await powerSyncRepository.supabase.auth.signOut()
		googleSignIn.signOut()
	}
	
	public nonisolated var user: AsyncStream<AuthenticationUser> {
		AsyncStream { continuation in
			Task {
				for await (_, session) in await powerSyncRepository.authState {
					let user = session?.user.toUser ?? .anonymous
					continuation.yield(user)
				}
			}
		}
//		powerSyncRepository.authState
//			.map { $0.1?.user.toUser ?? .anonymous }
//			.eraseToStream()
	}
}

public extension Supabase.User {
	var toUser: AuthenticationUser {
		AuthenticationUser(
			id: id.uuidString,
			email: email,
			username: userMetadata["username"]?.stringValue,
			fullName: userMetadata["full_name"]?.stringValue,
			avatarUrl: userMetadata["avatar_url"]?.stringValue,
			pushToken: userMetadata["push_token"]?.stringValue,
			isNewUser: createdAt == lastSignInAt
		)
	}
}
