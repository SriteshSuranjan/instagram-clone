import Dependencies
import Foundation
import RegexBuilder

private let emailRegExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
private let passwordRegExp = "******"
private let nameRegExp = "^[a-zA-Z0-9_.]{3,16}"
private let otpRegExp = "^[0-9]{6}"

extension ValidatorClient: DependencyKey {
	public static let liveValue = ValidatorClient()
}

extension EmailValidator: DependencyKey {
	public static let liveValue = EmailValidator(
		validate: { email in
			debugPrint("Email validate")
			guard !email.isEmpty else {
				throw EmailValidationError.empty
			}
			guard let value = _validate(emailRegExp, value: email) else {
				debugPrint("Invalid Email Throwed")
				throw EmailValidationError.invalid
			}
			return email
		}
	)
}

extension PasswordValidator: DependencyKey {
	public static let liveValue = PasswordValidator(
		validate: { password in
			debugPrint("Email validate")
			guard password.count >= passwordRegExp.count else {
				throw PasswordValidationError.lengthNotValid
			}
			return password
		}
	)
}

extension NameValidator: DependencyKey {
	public static let liveValue = NameValidator(
		validate: { name in
			debugPrint("UserName validate")
			guard !name.isEmpty else {
				throw NameValidationError.empty
			}
			guard let value = _validate(nameRegExp, value: name) else {
				throw NameValidationError.invalid
			}
			return value
		}
	)
}

extension StringLengthValidator: DependencyKey {
	public static let liveValue = StringLengthValidator(
		validate: { value, lowerBound in
			debugPrint("FullName validate")
			guard value.count >= lowerBound else {
				throw StringLengthValidationError(lowerBound: lowerBound)
			}
			return value
		}
	)
}

extension OTPValidator: DependencyKey {
	public static let liveValue = OTPValidator(
		validate: { value in
			guard !value.isEmpty else {
				throw OTPValidationError.empty
			}
			guard let value = _validate(otpRegExp, value: value) else {
				throw OTPValidationError.invalid
			}
			return value
		}
	)
}

private func _validate(_ rule: String, value: String) -> String? {
	NSPredicate(format: "SELF MATCHES %@", rule).evaluate(with: value) ? value : nil
}
