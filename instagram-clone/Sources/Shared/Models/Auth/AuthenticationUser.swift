import Foundation

public struct AuthenticationUser: Equatable, Codable, Sendable {
	public let id: String
	public let email: String?
	public let username: String?
	public let fullName: String?
	public let avatarUrl: String?
	public let pushToken: String?
	public let isNewUser: Bool

	public init(
		id: String,
		email: String? = nil,
		username: String? = nil,
		fullName: String? = nil,
		avatarUrl: String? = nil,
		pushToken: String? = nil,
		isNewUser: Bool = true
	) {
		self.id = id
		self.email = email
		self.username = username
		self.fullName = fullName
		self.avatarUrl = avatarUrl
		self.pushToken = pushToken
		self.isNewUser = isNewUser
	}

	public var isAnonymous: Bool {
		self == AuthenticationUser.anonymous
	}

	public static let anonymous = AuthenticationUser(id: "")
}

public enum AuthenticatonError: Error {
	case sendLoginEmailLinkFailure(message: String)
	case isLogInWithEmailLinkFailure(message: String)
	case logInWithEmailLinkFailure(message: String)
	case logInWithPasswordFailure(message: String)
	case logInWithPasswordCanceled(message: String)
	case logInWithAppleFailureFailure(message: String)
	case logInWithGoogleFailure(message: String)
	case logInWithGoogleCanceled(message: String)
	case logInWithGithubFailure(message: String)
	case logInWithGithubCanceled(message: String)
	case logInWithTwitterFailure(message: String)
	case logInWithTwitterCanceled(message: String)
	case sendPasswordResetEmailFailure(message: String)
	case resetPasswordFailure(message: String)
	case logOutFailure(message: String)
}

extension AuthenticatonError: LocalizedError {
	public var errorDescription: String? {
		switch self {
			case .sendLoginEmailLinkFailure(let message),
			     .isLogInWithEmailLinkFailure(let message),
			     .logInWithEmailLinkFailure(let message),
			     .logInWithPasswordFailure(let message),
			     .logInWithPasswordCanceled(let message),
			     .logInWithAppleFailureFailure(let message),
			     .logInWithGoogleFailure(let message),
			     .logInWithGoogleCanceled(let message),
			     .logInWithGithubFailure(let message),
			     .logInWithGithubCanceled(let message),
			     .logInWithTwitterFailure(let message),
			     .logInWithTwitterCanceled(let message),
			     .sendPasswordResetEmailFailure(let message),
			     .resetPasswordFailure(let message),
			     .logOutFailure(let message):
				return message
		}
	}
}
