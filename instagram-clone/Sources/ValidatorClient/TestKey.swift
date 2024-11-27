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
}
