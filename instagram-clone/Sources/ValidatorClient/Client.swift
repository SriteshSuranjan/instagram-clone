import Foundation
import DependenciesMacros

public struct ValidatorClient: Sendable {
	public let emailValidator: EmailValidator = .liveValue
	public let passwordValidator: PasswordValidator = .liveValue
}

public struct EmailValidator: Sendable {
	public var validate: @Sendable (_ email: String) throws -> String
}

public struct PasswordValidator: Sendable {
	public var validate: @Sendable (_ password: String) throws -> String
}

public enum EmailValidationError: LocalizedError {
	case empty
	case invalid
	
	public var errorDescription: String? {
		switch self {
		case .empty: return "This field is required"
		case .invalid: return "Email is not correct"
		}
	}
}

public enum PasswordValidationError: LocalizedError {
	case lengthNotValid
	
	public var errorDescription: String? {
		"6 Characters at least"
	}
}
