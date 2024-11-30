import SwiftUI
import ComposableArchitecture
import AppUI
import ValidatorClient
import UserClient
import Shared

@Reducer
public struct ChangePasswordReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var otp = OTP()
		var password = Password()
		var otpInput = ""
		var passwordInput = ""
		var otpValidationErrorMessage: String?
		var passwordValidationErrorMessage: String?
		var status: ChangePasswordStatus = .idle
		var focus: Field?
		var showPassword = false
		@Presents var alert: AlertState<Action.Alert>?
		var changePasswodButtonDisabled: Bool {
			status == .loading ||
			otp.invalid ||
			password.invalid
		}
		let email: String
		public init(email: String) {
			self.email = email
		}
		public enum ChangePasswordStatus: Equatable {
			case idle
			case loading
			case success
			case failure
			case invalidOtp
		}
		public enum Field: Hashable {
			case otp
			case password
		}
	}
	public enum Action: BindableAction {
		case alert(PresentationAction<Alert>)
		case actionChangePassword(validOTP: String, validPassword: String)
		case binding(BindingAction<State>)
		case cancelChangePasswordRequest
		case changePasswordFailed
		case changePasswordSuccess
		case onTapChangePassword
		case onTapBackButton
		case toggleShowPassword
		case updateOTPInput(String)
		case updatePasswordInput(String)
		case updateOTP(OTP)
		case updatePassword(Password)
		case delegate(Delegate)
		public enum Delegate {
			case onTapBackButton
		}
		@CasePathable
		public enum Alert: Equatable {
			case onLeavePageButtonTapped
		}
	}
	enum CancelID: Hashable {
		case requestChangePassword
	}
	@Dependency(\.userClient) var userClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
			action in
			switch action {
			case .alert(.presented(.onLeavePageButtonTapped)):
				state.alert = nil
				return .run { send in
					await send(.cancelChangePasswordRequest)
					await send(.delegate(.onTapBackButton))
				}
			case .cancelChangePasswordRequest:
				return .cancel(id: CancelID.requestChangePassword)
			case .alert:
				return .none
			case let .actionChangePassword(validOTP, validPassword):
				state.status = .loading
				return .run { [email = state.email] send in
					try await userClient.resetPassword(token: validOTP, email: email, newPassword: validPassword)
					await send(.changePasswordSuccess)
				} catch: { error, send in
					await send(.changePasswordFailed)
				}
					.cancellable(id: CancelID.requestChangePassword, cancelInFlight: true)
			case .binding(.set(\State.focus, nil)):
				let otpEffect: Effect<Action> = state.otp.invalid ? .none : .run { [previousOTP = state.otp] send in
					let shouldValidate = previousOTP.status == .pure
					if shouldValidate {
						@Dependency(\.validatorClient.otpValidator) var otpValidator
						_ = try otpValidator.validate(previousOTP.value)
					}
					let updatedOTP = previousOTP.valid(previousOTP.value)
					await send(.updateOTP(updatedOTP), animation: .snappy)
					
				} catch: { [previousOTP = state.otp] error, send in
					guard let otpValidationError = error as? OTPValidationError else {
						return
					}
					let updatedOTPState = previousOTP.dirty(previousOTP.value, error: otpValidationError)
					await send(.updateOTP(updatedOTPState), animation: .snappy)
				}
				let passwordEffect: Effect<Action> = state.password.invalid ? .none : .run { [previousPassword = state.password] send in
					let shouldValidate = previousPassword.status == .pure
					if shouldValidate {
						@Dependency(\.validatorClient.passwordValidator) var passwordValidator
						_ = try passwordValidator.validate(previousPassword.value)
					}
					let updatedPassword = previousPassword.valid(previousPassword.value)
					await send(.updatePassword(updatedPassword), animation: .snappy)
				}
				return .merge(
					otpEffect,
					passwordEffect
				)
			case .binding:
				return .none
			case .changePasswordFailed:
				state.status = .failure
				return .none
			case .changePasswordSuccess:
				state.status = .success
				return .none
			case .delegate:
				return .none
			case .onTapChangePassword:
				return Effect.concatenate(
					.send(.binding(.set(\State.focus, nil))),
					.run { [otp = state.otp, password = state.password] send in
						guard otp.validated, password.validated else {
							return
						}
						await send(.actionChangePassword(validOTP: otp.value, validPassword: password.value))
					}
				)
			case .onTapBackButton:
				state.alert = AlertState(
					title: {
						TextState("Are you sure you want to go back?")
					},
					actions: {
						ButtonState(role: .cancel) {
							TextState("Cancel")
						}
						ButtonState(role: .destructive, action: .send(.onLeavePageButtonTapped)) {
							TextState("Go back")
						}
					},
					message: {
						TextState("If you go back now, you'll loose all the edits you've made.")
					}
				)
				return .none
			case .toggleShowPassword:
				state.showPassword.toggle()
				return .none
			case let .updateOTPInput(updatedOTPInput):
				if state.otpInput == updatedOTPInput {
					return .none
				}
				state.otpInput = updatedOTPInput
				return .run { [previousOTP = state.otp] send in
					let shouldValidate = previousOTP.invalid
					let updatedOTPState: OTP
					if shouldValidate {
						@Dependency(\.validatorClient.otpValidator) var otpValidator
						_ = try otpValidator.validate(updatedOTPInput)
						updatedOTPState = previousOTP.valid(updatedOTPInput)
					} else {
						updatedOTPState = previousOTP.pure(updatedOTPInput)
					}
					await send(.updateOTP(updatedOTPState), animation: .snappy)
				} catch: { [previousOTP = state.otp] error, send in
					guard let otpError = error as? OTPValidationError else {
						return
					}
					let updatedOTPState = previousOTP.dirty(updatedOTPInput, error: otpError)
					await send(.updateOTP(updatedOTPState), animation: .snappy)
				}
				.debounce(id: "validateOTP", for: .milliseconds(300), scheduler: DispatchQueue.main)
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
				
			case let .updateOTP(updatedOTP):
				state.otp = updatedOTP
				if let error = state.otp.error as? OTPValidationError {
					state.otpValidationErrorMessage = error.errorDescription
				} else {
					state.otpValidationErrorMessage = nil
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
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}
}

public struct ChangePasswordView: View {
	@Bindable var store: StoreOf<ChangePasswordReducer>
	@FocusState var focus: ChangePasswordReducer.State.Field?
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<ChangePasswordReducer>) {
		self.store = store
	}
	public var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: AppSpacing.md) {
				AuthTextField(
					placeholder: "OTP",
					errorMessage: store.otpValidationErrorMessage,
					input: $store.otpInput.sending(\.updateOTPInput)
				)
				.focused($focus, equals: .otp)
				.padding(.top, AppSpacing.xxxlg * 3)
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
				.padding(.vertical, AppSpacing.md)
				AuthButton(
					isLoading: store.status == .loading,
					text: "Change password",
					outlined: false,
					style: AppButtonStyle(
						foregroundColor: Assets.Colors.white,
						backgroundColor: Assets.Colors.blue,
						textStyle: textTheme.labelLarge,
						fullWidth: true
					)) {
						store.send(.onTapChangePassword)
					}
					.disabled(store.changePasswodButtonDisabled)
			}
			.padding(.horizontal, AppSpacing.xlg)
		}
		.toolbar(.hidden, for: .navigationBar)
		.safeAreaInset(edge: .top) {
			AppNavigationBar(title: "Password Recovery") {
				store.send(.onTapBackButton)
			}
			.padding(.horizontal, AppSpacing.lg)
		}
		.bind($store.focus, to: $focus)
		.alert($store.scope(state: \.alert, action: \.alert))
	}
	
	@ViewBuilder
	private func showPasswordIconView() -> Image {
		store.showPassword ? Image(systemName: "eye.slash.fill") : Image(systemName: "eye.fill")
	}
}
