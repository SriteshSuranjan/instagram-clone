import Dependencies
import Foundation
import RegexBuilder

private let emailRegExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
private let passwordRegExp = "******"

extension ValidatorClient: DependencyKey {
	public static let liveValue = ValidatorClient()
}

extension EmailValidator: DependencyKey {
	public static let liveValue = EmailValidator(
		validate: { email in
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
			guard password.count >= passwordRegExp.count else {
				throw PasswordValidationError.lengthNotValid
			}
			return password
		}
	)
}

private func _validate(_ rule: String, value: String) -> String? {
	NSPredicate(format: "SELF MATCHES %@", rule).evaluate(with: value) ? value : nil
}
