import SwiftUI
import ComposableArchitecture
import AppUI
import ValidatorClient
import Shared
import UserClient

@Reducer
public struct SignUpFormReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var email = Email()
		var fullName = FullName()
		var userName = UserName()
		var password = Password()
		var previousFocus: Field?
		var focus: Field?
		var emailInput: String = ""
		var passwordInput: String = ""
		var fullNameInput: String = ""
		var userNameInput: String = ""
		var emailValidationErrorMessage: String?
		var passwordValidationErrorMessage: String?
		var fullNameValidationErrorMessage: String?
		var userNameValidationErrorMessage: String?
		var showPassword = false
		public init() {}
		
		@CasePathable
		public enum Field: Hashable, Sendable {
			case email
			case fullName
			case userName
			case password
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case resignTextFieldFocus
		case toggleShowPassword
		case updateEmailInput(String)
		case updatePasswordInput(String)
		case updateFullNameInput(String)
		case updateUserNameInput(String)
		case updateEmail(Email)
		case updatePassword(Password)
		case updateFullName(FullName)
		case updateUserName(UserName)
	}
	
	@Dependency(\.userClient) var userClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding(.set(\State.focus, .email)):
				state.previousFocus = .email
				return .none
			case .binding(.set(\State.focus, .password)):
				state.previousFocus = .password
				return .none
			case .binding(.set(\State.focus, .fullName)):
				state.previousFocus = .fullName
				return .none
			case .binding(.set(\State.focus, .userName)):
				state.previousFocus = .userName
				return .none
			case .binding(.set(\State.focus, nil)):
				let emailEffect: Effect<Action> = state.email.invalid ? .none : .run { [previousEmail = state.email] send in
					let shouldValidate = previousEmail.status == .pure
					 if shouldValidate {
						 @Dependency(\.validatorClient.emailValidator) var emailValidator
						 _ = try emailValidator.validate(previousEmail.value)
					 }
					 let updatedEmail = previousEmail.valid(previousEmail.value)
					 await send(.updateEmail(updatedEmail), animation: .snappy)
				 } catch: { [previousEmail = state.email] error, send in
					 guard let emailError = error as? EmailValidationError else {
						 return
					 }
					 let updatedEmailState = previousEmail.dirty(previousEmail.value, error: emailError)
					 await send(.updateEmail(updatedEmailState), animation: .snappy)
				 }
				let fullNameEffect: Effect<Action> = state.fullName.invalid ? .none : .run { [previousFullName = state.fullName] send in
					let shouldValidate = previousFullName.status == .pure
					 if shouldValidate {
						 @Dependency(\.validatorClient.stringLengthValidator) var stringLengthValidator
						 _ = try stringLengthValidator.validate(previousFullName.value, 1)
					 }
					 let updatedFullName = previousFullName.valid(previousFullName.value)
					 await send(.updateFullName(updatedFullName), animation: .snappy)
				 } catch: { [previousFullName = state.fullName] error, send in
					 guard let fullNameError = error as? StringLengthValidationError else {
						 return
					 }
					 let updatedFullNameState = previousFullName.dirty(previousFullName.value, error: fullNameError)
					 await send(.updateFullName(updatedFullNameState), animation: .snappy)
				 }
				let userNameEffect: Effect<Action> = state.userName.invalid ? .none : .run { [previousUserName = state.userName] send in
					let shouldValidate = previousUserName.status == .pure
					 if shouldValidate {
						 @Dependency(\.validatorClient.nameValidator) var nameValidator
						 _ = try nameValidator.validate(previousUserName.value)
					 }
					 let updatedUserName = previousUserName.valid(previousUserName.value)
					 await send(.updateUserName(updatedUserName), animation: .snappy)
				 } catch: { [previousUserName = state.userName] error, send in
					 guard let userNameError = error as? NameValidationError else {
						 return
					 }
					 let updatedUserNameState = previousUserName.dirty(previousUserName.value, error: userNameError)
					 await send(.updateUserName(updatedUserNameState), animation: .snappy)
				 }
				let passwordEffect: Effect<Action> = state.password.invalid ? .none : .run { [previousPassword = state.password] send in
					let shouldValidate = previousPassword.status == .pure
					 if shouldValidate {
						 @Dependency(\.validatorClient.passwordValidator) var passwordValidator
						 _ = try passwordValidator.validate(previousPassword.value)
					 }
					 let updatedPassword = previousPassword.valid(previousPassword.value)
					 await send(.updatePassword(updatedPassword), animation: .snappy)
				 } catch: { [previousPassword = state.password] error, send in
					 guard let passwordError = error as? PasswordValidationError else {
						 return
					 }
					 let updatedPasswordState = previousPassword.dirty(previousPassword.value, error: passwordError)
					 await send(.updatePassword(updatedPasswordState), animation: .snappy)
				 }
				state.previousFocus = nil
				return .merge(
					emailEffect,
					fullNameEffect,
					userNameEffect,
					passwordEffect
				)
			case .binding:
				return .none
			case .resignTextFieldFocus:
				return .send(.binding(.set(\State.focus, nil)))
			case .toggleShowPassword:
				state.showPassword.toggle()
				return .none
			case let .updateEmailInput(updatedEmailInput):
				guard state.emailInput != updatedEmailInput else {
					return .none
				}
				state.emailInput = updatedEmailInput
				return .run { [previousEmail = state.email] send in
					let shouldValidate = previousEmail.invalid
					let updatedEmailState: Email
					if shouldValidate {
						@Dependency(\.validatorClient.emailValidator) var emailValidator
						_ = try emailValidator.validate(updatedEmailInput)
						updatedEmailState = previousEmail.valid(updatedEmailInput)
					} else {
						updatedEmailState = previousEmail.pure(updatedEmailInput)
					}
					
					await send(.updateEmail(updatedEmailState), animation: .snappy)
				} catch: { [previousEmail = state.email] error, send in
					guard let emailError = error as? EmailValidationError else {
						return
					}
					let updatedEmailState = previousEmail.dirty(updatedEmailInput, error: emailError)
					await send(.updateEmail(updatedEmailState), animation: .snappy)
				}
				.debounce(id: "validateEmail", for: .milliseconds(300), scheduler: DispatchQueue.main)
			case let .updatePasswordInput(updatedPasswordInput):
				guard state.passwordInput != updatedPasswordInput else {
					return .none
				}
				state.passwordInput = updatedPasswordInput
				return .run { [previousPassword = state.password] send in
					let shouldValidate = previousPassword.invalid
					let updatedPasswordState: Password
					if shouldValidate {
						@Dependency(\.validatorClient.passwordValidator) var passwordValidator
						_ = try passwordValidator.validate(updatedPasswordInput)
						updatedPasswordState = previousPassword.valid(updatedPasswordInput)
					} else {
						updatedPasswordState = previousPassword.pure(updatedPasswordInput)
					}
					await send(.updatePassword(updatedPasswordState), animation: .snappy)
				} catch: { [previousPassword = state.password] error, send in
					guard let passwordError = error as? PasswordValidationError else {
						return
					}
					let updatedPasswordState = previousPassword.dirty(updatedPasswordInput, error: passwordError)
					await send(.updatePassword(updatedPasswordState), animation: .snappy)
				}
				.debounce(id: "validatePassword", for: .milliseconds(300), scheduler: DispatchQueue.main)
			case let .updateFullNameInput(updatedFullNameInput):
				guard state.fullNameInput != updatedFullNameInput else {
					return .none
				}
				state.fullNameInput = updatedFullNameInput
				return .run { [previousFullName = state.fullName] send in
					let shouldValidate = previousFullName.invalid
					let updatedFullNameState: FullName
					if shouldValidate {
						@Dependency(\.validatorClient.stringLengthValidator) var stringLengthValidator
						_ = try stringLengthValidator.validate(updatedFullNameInput, 1)
						updatedFullNameState = previousFullName.valid(updatedFullNameInput)
					} else {
						updatedFullNameState = previousFullName.pure(updatedFullNameInput)
					}
					await send(.updateFullName(updatedFullNameState), animation: .snappy)
				} catch: { [previousFullName = state.fullName] error, send in
					guard let fullNameError = error as? StringLengthValidationError else {
						return
					}
					let updatedFullNameState = previousFullName.dirty(updatedFullNameInput, error: fullNameError)
					await send(.updateFullName(updatedFullNameState), animation: .snappy)
				}
				.debounce(id: "validateFullName", for: .milliseconds(300), scheduler: DispatchQueue.main)
			case let .updateUserNameInput(updatedUserNameInput):
				guard state.userNameInput != updatedUserNameInput else {
					return .none
				}
				state.userNameInput = updatedUserNameInput
				return .run { [previousUserName = state.userName] send in
					let shouldValidate = previousUserName.invalid
					let updatedUserNameState: UserName
					if shouldValidate {
						@Dependency(\.validatorClient.nameValidator) var nameValidator
						_ = try nameValidator.validate(updatedUserNameInput)
						updatedUserNameState = previousUserName.valid(updatedUserNameInput)
					} else {
						updatedUserNameState = previousUserName.pure(updatedUserNameInput)
					}
					await send(.updateUserName(updatedUserNameState), animation: .snappy)
				} catch: { [previousUserName = state.userName] error, send in
					guard let userNameError = error as? NameValidationError else {
						return
					}
					let updatedUserNameState = previousUserName.dirty(updatedUserNameInput, error: userNameError)
					await send(.updateUserName(updatedUserNameState), animation: .snappy)
				}
				.debounce(id: "validateUserName", for: .milliseconds(300), scheduler: DispatchQueue.main)
			case let .updateEmail(updatedEmail):
				state.email = updatedEmail
				if let error = state.email.error as? EmailValidationError {
					state.emailValidationErrorMessage = error.errorDescription
				} else {
					state.emailValidationErrorMessage = nil
				}
				return .none
			case let .updatePassword(updatedPassword):
				state.password = updatedPassword
				if let error = state.password.error as? PasswordValidationError {
					state.passwordValidationErrorMessage = error.errorDescription
				} else {
					state.passwordValidationErrorMessage = nil
				}
				return .none
			case let .updateFullName(updatedFullName):
				state.fullName = updatedFullName
				if let error = state.fullName.error as? StringLengthValidationError {
					state.fullNameValidationErrorMessage = error.errorDescription
				} else {
					state.fullNameValidationErrorMessage = nil
				}
				return .none
			case let .updateUserName(updatedUserName):
				state.userName = updatedUserName
				if let error = state.userName.error as? NameValidationError {
					state.userNameValidationErrorMessage = error.errorDescription
				} else {
					state.userNameValidationErrorMessage = nil
				}
				return .none
			}
		}
	}
}

public struct SignUpForm: View {
	@Bindable var store: StoreOf<SignUpFormReducer>
	@FocusState var focus: SignUpFormReducer.State.Field?
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<SignUpFormReducer>) {
		self.store = store
	}
	public var body: some View {
		VStack(spacing: AppSpacing.md) {
			AuthTextField(
				placeholder: "Email",
				errorMessage: store.emailValidationErrorMessage,
				input: $store.emailInput.sending(\.updateEmailInput)
			)
			.focused($focus, equals: .email)
			AuthTextField(
				placeholder: "Name",
				errorMessage: store.fullNameValidationErrorMessage,
				input: $store.fullNameInput.sending(\.updateFullNameInput)
			)
			.focused($focus, equals: .fullName)
			
			AuthTextField(
				placeholder: "Username",
				errorMessage: store.userNameValidationErrorMessage,
				input: $store.userNameInput.sending(\.updateUserNameInput)
			)
			.focused($focus, equals: .userName)
			
			AuthTextField(
				placeholder: "Password",
				errorMessage: store.passwordValidationErrorMessage,
				isSecure: true,
				showSensitive: store.showPassword,
				input: $store.passwordInput.sending(\.updatePasswordInput)
			) {
				Button {
					store.send(.toggleShowPassword, animation: .none)
				} label: {
					showPasswordIconView()
						.foregroundStyle(Assets.Colors.customAdaptiveColor(colorScheme, light: Assets.Colors.gray))
				}
				.noneEffect()
			}
			.focused($focus, equals: .password)
		}
		.bind($store.focus, to: $focus)
	}
	
	@ViewBuilder
	private func showPasswordIconView() -> Image {
		store.showPassword ? Image(systemName: "eye.slash.fill") : Image(systemName: "eye.fill")
	}
}
