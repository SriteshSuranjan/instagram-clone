import Dependencies

public extension DependencyValues {
	var validatorClient: ValidatorClient {
		get { self[ValidatorClient.self] }
		set { self[ValidatorClient.self] = newValue }
	}

	var emailValidator: EmailValidator {
		get { self[EmailValidator.self] }
		set { self[EmailValidator.self] = newValue }
	}

	var passwordValidator: PasswordValidator {
		get { self[PasswordValidator.self] }
		set { self[PasswordValidator.self] = newValue }
	}
	
	var stringLengthValidator: StringLengthValidator {
		get { self[StringLengthValidator.self] }
		set { self[StringLengthValidator.self] = newValue }
	}
	
	var nameLengthValidator: NameValidator {
		get { self[NameValidator.self] }
		set { self[NameValidator.self] = newValue }
	}
	
	var otpValidator: OTPValidator {
		get { self[OTPValidator.self] }
		set { self[OTPValidator.self] = newValue }
	}
}
