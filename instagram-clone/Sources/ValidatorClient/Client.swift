import Foundation
import DependenciesMacros

public struct ValidatorClient: Sendable {
	public let emailValidator: EmailValidator = .liveValue
	public let passwordValidator: PasswordValidator = .liveValue
	public let stringLengthValidator: StringLengthValidator = .liveValue
	public let nameValidator: NameValidator = .liveValue
	public let otpValidator: OTPValidator = .liveValue
}

public struct EmailValidator: Sendable {
	public var validate: @Sendable (_ email: String) throws -> String
}

public struct PasswordValidator: Sendable {
	public var validate: @Sendable (_ password: String) throws -> String
}

public struct NameValidator: Sendable {
	public var validate: @Sendable (_ name: String) throws -> String
}

public struct StringLengthValidator: Sendable {
	public var validate: @Sendable (_ value: String, _ lowerBound: Int) throws -> String
}

public struct OTPValidator: Sendable {
	public var validate: @Sendable (_ value: String) throws -> String
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

public struct StringLengthValidationError: LocalizedError {
	let lowerBound: Int
	public init(lowerBound: Int) {
		self.lowerBound = lowerBound
	}
	public var errorDescription: String? {
		"\(lowerBound) Characters at least"
	}
}

public enum PasswordValidationError: LocalizedError {
	case lengthNotValid
	
	public var errorDescription: String? {
		"6 Characters at least"
	}
}

public enum NameValidationError: LocalizedError {
	case empty
	case invalid
	
	public var errorDescription: String? {
		switch self {
		case .empty: return "This field is required"
		case .invalid: return "Username must be between 3 and 16 characters. Also, it can only contain letters, numbers, periods, and underscores."
		}
	}
}

public enum OTPValidationError: LocalizedError {
	case empty
	case invalid
	
	public var errorDescription: String? {
		switch self {
		case .empty: return "This field is required"
		case .invalid: return "OTP must be 6 number characters."
		}
	}
}
