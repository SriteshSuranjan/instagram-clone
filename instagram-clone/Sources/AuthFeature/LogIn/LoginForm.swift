import AppUI
import ComposableArchitecture
import Foundation
import Shared
import SwiftUI
import ValidatorClient

@Reducer
public struct LoginFormReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var previousFocus: Field?
		var focus: Field?
		var emailInput: String = ""
		var passwordInput: String = ""
		var emailValidationErrorMessage: String?
		var passwordValidationErrorMessage: String?
		var email = Email()
		var password = Password()
		var showPassword = false
		public enum Field: Hashable, Sendable {
			case email
			case password
		}

		public init() {}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case resignTextFieldFocus
		case toggleShowPassword
		case updateEmailInput(String)
		case updatePasswordInput(String)
		case updateEmail(Email)
		case updatePassword(Password)
	}

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
			case .binding(.set(\State.focus, nil)):
				if state.previousFocus == .email {
					if state.email.invalid {
						return .none
					}
					return .run { [previousEmail = state.email] send in
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
				} else if state.previousFocus == .password {
					if state.email.invalid {
						return .none
					}
					return .run { [previousPassword = state.password] send in
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
				}
				state.previousFocus = nil
				return .none
			case .binding:
				return .none
			case .resignTextFieldFocus:
				return .send(.binding(.set(\State.focus, nil)))
			case .toggleShowPassword:
				state.showPassword.toggle()
				return .none
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
			case let .updatePasswordInput(updatedPasswordInput):
				if state.passwordInput == updatedPasswordInput {
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
			case let .updateEmailInput(updatedEmailInput):
				if state.emailInput == updatedEmailInput {
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
			}
		}
	}
}

public struct LoginForm: View {
	@Bindable var store: StoreOf<LoginFormReducer>
	@FocusState var focus: LoginFormReducer.State.Field?
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<LoginFormReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack {
			emailTextField()
			passwordTextField()
		}
		.bind($store.focus, to: $focus)
	}

	@ViewBuilder
	private func emailTextField() -> some View {
		VStack(alignment: .leading, spacing: 0) {
			TextField("Email", text: $store.emailInput.sending(\.updateEmailInput))
				.focused($focus, equals: .email)
				.appTextField(
					font: textTheme.bodyLarge.font,
					foregroundColor: Assets.Colors.bodyColor,
					accentColor: Assets.Colors.bodyColor,
					backgroundColor: Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.brightGray, dark: Assets.Colors.dark),
					keyboardType: .emailAddress,
					returnKeyType: .next
				)
			if let emailErrorMessage = store.emailValidationErrorMessage {
				HStack {
					Text(emailErrorMessage)
						.font(textTheme.bodyLarge.font)
						.foregroundStyle(Assets.Colors.red)
						.transition(.move(edge: .top))
					Spacer()
				}
			}
		}
		.padding(.top, AppSpacing.md)
	}

	@ViewBuilder
	private func passwordTextField() -> some View {
		VStack {
			displayPasswordTextField()
				.focused($focus, equals: .password)
				.appTextField(
					font: textTheme.bodyLarge.font,
					foregroundColor: Assets.Colors.bodyColor,
					accentColor: Assets.Colors.bodyColor,
					backgroundColor: Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.brightGray, dark: Assets.Colors.dark),
					keyboardType: .default,
					returnKeyType: .done,
					trailingView: {
						Button {
							store.send(.toggleShowPassword, animation: .none)
						} label: {
							showPasswordIconView()
								.foregroundStyle(Assets.Colors.customAdaptiveColor(colorScheme, light: Assets.Colors.gray))
						}
						.noneEffect()
					}
				)
			if let passwordErrorMessage = store.passwordValidationErrorMessage {
				HStack {
					Text(passwordErrorMessage)
						.font(textTheme.bodyLarge.font)
						.foregroundStyle(Assets.Colors.red)
						.transition(.move(edge: .top))
					Spacer()
				}
			}
		}
		.padding(.top, AppSpacing.md)
	}

	@ViewBuilder
	private func showPasswordIconView() -> Image {
		store.showPassword ? Image(systemName: "eye.slash.fill") : Image(systemName: "eye.fill")
	}

	@ViewBuilder
	private func displayPasswordTextField() -> some View {
		ZStack {
			TextField("Password", text: $store.passwordInput.sending(\.updatePasswordInput))
				.opacity(store.showPassword ? 1 : 0)

			SecureField("Password", text: $store.passwordInput.sending(\.updatePasswordInput))
				.opacity(store.showPassword ? 0 : 1)
		}
	}
}
