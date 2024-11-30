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

/// Represents various authentication-related errors.
public enum AuthenticationError: Error {
	// Specific Authentication Errors
	case sendLoginEmailLinkFailure(message: String, underlyingError: Error?)
	case isLogInWithEmailLinkFailure(message: String, underlyingError: Error?)
	case logInWithEmailLinkFailure(message: String, underlyingError: Error?)
	case logInWithPasswordFailure(message: String, underlyingError: Error?)
	case logInWithPasswordCanceled(message: String, underlyingError: Error?)
	case logInWithAppleFailure(message: String, underlyingError: Error?)
	case logInWithGoogleFailure(message: String, underlyingError: Error?)
	case logInWithGoogleCanceled(message: String, underlyingError: Error?)
	case logInWithGithubFailure(message: String, underlyingError: Error?)
	case logInWithGithubCanceled(message: String, underlyingError: Error?)
	case logInWithTwitterFailure(message: String, underlyingError: Error?)
	case logInWithTwitterCanceled(message: String, underlyingError: Error?)
	case sendPasswordResetEmailFailure(message: String, underlyingError: Error?)
	case resetPasswordFailure(message: String, underlyingError: Error?)
	case logOutFailure(message: String, underlyingError: Error?)

	// General Wrapping Case
	case underlying(error: Error, message: String?)
}

extension AuthenticationError: LocalizedError {
	public var errorDescription: String? {
		// First, check if there's an underlying error that provides an errorDescription
		if let underlyingError = underlyingError as? LocalizedError,
		   let description = underlyingError.errorDescription
		{
			return description
		}

		// If not, use the custom message associated with the error case
		switch self {
		case .sendLoginEmailLinkFailure(let message, _),
		     .isLogInWithEmailLinkFailure(let message, _),
		     .logInWithEmailLinkFailure(let message, _),
		     .logInWithPasswordFailure(let message, _),
		     .logInWithPasswordCanceled(let message, _),
		     .logInWithAppleFailure(let message, _),
		     .logInWithGoogleFailure(let message, _),
		     .logInWithGoogleCanceled(let message, _),
		     .logInWithGithubFailure(let message, _),
		     .logInWithGithubCanceled(let message, _),
		     .logInWithTwitterFailure(let message, _),
		     .logInWithTwitterCanceled(let message, _),
		     .sendPasswordResetEmailFailure(let message, _),
		     .resetPasswordFailure(let message, _),
		     .logOutFailure(let message, _):
			return message
		case .underlying(_, let message):
			return message
		}
	}

	public var failureReason: String? {
		// First, check if the underlying error provides a failureReason
		if let underlyingError = underlyingError as? LocalizedError,
		   let reason = underlyingError.failureReason
		{
			return reason
		}

		// Optionally, provide custom failure reasons based on the error case
		return nil
	}

	public var recoverySuggestion: String? {
		// First, check if the underlying error provides a recoverySuggestion
		if let underlyingError = underlyingError as? LocalizedError,
		   let suggestion = underlyingError.recoverySuggestion
		{
			return suggestion
		}

		// If not, provide the custom recovery suggestion based on the error case
		switch self {
		case .sendLoginEmailLinkFailure:
			return "Please try again later or contact support."
		case .isLogInWithEmailLinkFailure:
			return "Ensure the email link you're using is valid and not expired."
		case .logInWithEmailLinkFailure:
			return "Please verify your email and click the correct login link."
		case .logInWithPasswordFailure:
			return "Double-check your password or reset it if you've forgotten it."
		case .logInWithPasswordCanceled:
			return "Login with password was canceled. You can try logging in again."
		case .logInWithAppleFailure:
			return "Apple Sign-In failed. Please try again later."
		case .logInWithGoogleFailure:
			return "Google Sign-In failed. Please ensure you have a stable internet connection."
		case .logInWithGoogleCanceled:
			return "Google Sign-In was canceled. You can try logging in again."
		case .logInWithGithubFailure:
			return "GitHub Sign-In failed. Please try again later."
		case .logInWithGithubCanceled:
			return "GitHub Sign-In was canceled. You can try logging in again."
		case .logInWithTwitterFailure:
			return "Twitter Sign-In failed. Please try again later."
		case .logInWithTwitterCanceled:
			return "Twitter Sign-In was canceled. You can try logging in again."
		case .sendPasswordResetEmailFailure:
			return "Failed to send password reset email. Please try again."
		case .resetPasswordFailure:
			return "Failed to reset your password. Please ensure your new password meets the requirements."
		case .logOutFailure:
			return "Log out failed. Please try again."
		case .underlying:
			return "An unexpected error occurred. Please try again."
		}
	}

	// Helper to access the underlyingError regardless of the error case
	private var underlyingError: Error? {
		switch self {
		case .sendLoginEmailLinkFailure(_, let error),
		     .isLogInWithEmailLinkFailure(_, let error),
		     .logInWithEmailLinkFailure(_, let error),
		     .logInWithPasswordFailure(_, let error),
		     .logInWithPasswordCanceled(_, let error),
		     .logInWithAppleFailure(_, let error),
		     .logInWithGoogleFailure(_, let error),
		     .logInWithGoogleCanceled(_, let error),
		     .logInWithGithubFailure(_, let error),
		     .logInWithGithubCanceled(_, let error),
		     .logInWithTwitterFailure(_, let error),
		     .logInWithTwitterCanceled(_, let error),
		     .sendPasswordResetEmailFailure(_, let error),
		     .resetPasswordFailure(_, let error),
		     .logOutFailure(_, let error):
			return error
		case .underlying(let error, _):
			return error
		}
	}
	
	public var errorCode: Int? {
		if let nsError = underlyingError as? NSError {
			return nsError.code
		}
		return nil
	}
}

// extension AuthenticationError: LocalizedError {
//	public var errorDescription: String? {
//		switch self {
//		case .sendLoginEmailLinkFailure(let message, _),
//		     .isLogInWithEmailLinkFailure(let message, _),
//		     .logInWithEmailLinkFailure(let message, _),
//		     .logInWithPasswordFailure(let message, _),
//		     .logInWithPasswordCanceled(let message, _),
//		     .logInWithAppleFailure(let message, _),
//		     .logInWithGoogleFailure(let message, _),
//		     .logInWithGoogleCanceled(let message, _),
//		     .logInWithGithubFailure(let message, _),
//		     .logInWithGithubCanceled(let message, _),
//		     .logInWithTwitterFailure(let message, _),
//		     .logInWithTwitterCanceled(let message, _),
//		     .sendPasswordResetEmailFailure(let message, _),
//		     .resetPasswordFailure(let message, _),
//		     .logOutFailure(let message, _):
//			return message
//		case .underlying(let error, let message):
//			return message ?? error.localizedDescription
//		}
//	}
//
//	public var failureReason: String? {
//		switch self {
//		case .sendLoginEmailLinkFailure, .isLogInWithEmailLinkFailure, .logInWithEmailLinkFailure,
//		     .logInWithPasswordFailure, .logInWithPasswordCanceled, .logInWithAppleFailure,
//		     .logInWithGoogleFailure, .logInWithGoogleCanceled, .logInWithGithubFailure,
//		     .logInWithGithubCanceled, .logInWithTwitterFailure, .logInWithTwitterCanceled,
//		     .sendPasswordResetEmailFailure, .resetPasswordFailure, .logOutFailure:
//			return nil // You can provide specific reasons if needed
//		case .underlying(let error, _):
//			return error.localizedDescription
//		}
//	}
//
//	public var recoverySuggestion: String? {
//		switch self {
//		case .sendLoginEmailLinkFailure:
//			return "Please try again later or contact support."
//		case .isLogInWithEmailLinkFailure:
//			return "Ensure the email link you're using is valid and not expired."
//		case .logInWithEmailLinkFailure:
//			return "Please verify your email and click the correct login link."
//		case .logInWithPasswordFailure:
//			return "Double-check your password or reset it if you've forgotten it."
//		case .logInWithPasswordCanceled:
//			return "Login with password was canceled. You can try logging in again."
//		case .logInWithAppleFailure:
//			return "Apple Sign-In failed. Please try again later."
//		case .logInWithGoogleFailure:
//			return "Google Sign-In failed. Please ensure you have a stable internet connection."
//		case .logInWithGoogleCanceled:
//			return "Google Sign-In was canceled. You can try logging in again."
//		case .logInWithGithubFailure:
//			return "GitHub Sign-In failed. Please try again later."
//		case .logInWithGithubCanceled:
//			return "GitHub Sign-In was canceled. You can try logging in again."
//		case .logInWithTwitterFailure:
//			return "Twitter Sign-In failed. Please try again later."
//		case .logInWithTwitterCanceled:
//			return "Twitter Sign-In was canceled. You can try logging in again."
//		case .sendPasswordResetEmailFailure:
//			return "Failed to send password reset email. Please try again."
//		case .resetPasswordFailure:
//			return "Failed to reset your password. Please ensure your new password meets the requirements."
//		case .logOutFailure:
//			return "Log out failed. Please try again."
//		case .underlying:
//			return "An unexpected error occurred. Please try again."
//		}
//	}
// }

// public protocol AuthenticationError: Error, CustomStringConvertible {
//		var error: Error { get }
//		var description: String { get }
// }
//
// extension AuthenticationError {
//	public var description: String {
//		"Authentication exception error: \(error)"
//	}
// }
//
// public struct SendLoginEmailLinkFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct IsLogInWithEmailLinkFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithEmailLinkFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithPasswordFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithAppleFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithGoogleFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithPasswordCanceled: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithGithubFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithGoogleCanceled: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithGithubCanceled: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithTwitterFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogInWithTwitterCanceled: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct SendPasswordResetEmailFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct ResetPasswordFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
//
// public struct LogOutFailure: AuthenticationError {
//	public let error: Error
//	public init(_ error: Error) {
//		self.error = error
//	}
// }
