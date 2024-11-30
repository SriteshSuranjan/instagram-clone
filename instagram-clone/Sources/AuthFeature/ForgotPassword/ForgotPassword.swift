import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import Shared
import ValidatorClient
import UserClient

@Reducer
public struct ForgotPasswordReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var status: ForgotPasswordStatus = .idle
		var emailInput: String = ""
		var emailValidationErrorMessage: String?
		var email = Email()
		var focus: Field?
		var nextButtonDisabled: Bool {
			status == .loading ||
			email.invalid
		}
		public init() {}
		public enum Field: Hashable {
			case email
		}
		public enum ForgotPasswordStatus {
			case idle
			case loading
			case success
			case failure
			case tooManyRequests
		}
	}
	public enum Action: BindableAction {
		case actionSendPasswordReset(validEmail: String)
		case binding(BindingAction<State>)
		case delegate(Delegate)
		case onTapNextButton
		case updateEmailInput(String)
		case updateEmail(Email)
		case sendPasswordResetSuccess
		case sendPasswordResetFailed(State.ForgotPasswordStatus)
		
		public enum Delegate {
			case onTapBackButton
			case sendPasswordResetSuccess(validEmail: String)
		}
	}
	
	@Dependency(\.userClient) var userClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
			action in
			switch action {
			case let .actionSendPasswordReset(validEmail):
				state.status = .loading
				return .run { send in
					try await userClient.sendPasswordResetEmail(email: validEmail, redirectTo: nil)
					await send(.sendPasswordResetSuccess)
				} catch: { error, send in
					guard let authenticationError = error as? AuthenticationError else {
						return
					}
					if let errorCode = authenticationError.errorCode,
						 errorCode == 429 {
						await send(.sendPasswordResetFailed(.tooManyRequests))
					} else {
						await send(.sendPasswordResetFailed(.failure))
					}
				}
				
			case .binding(.set(\State.focus, nil)):
				return state.email.invalid ? .none : .run { [previousEmail = state.email] send in
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
			case .binding:
				return .none
			case .onTapNextButton:
				return .concatenate(
					.send(.binding(.set(\State.focus, nil))),
					.run { [email = state.email] send in
						guard email.validated else {
							return
						}
						await send(.actionSendPasswordReset(validEmail: email.value))
					}
				)
			case .delegate:
				return .none
			case let .sendPasswordResetFailed(status):
				state.status = status
				return .none
			case .sendPasswordResetSuccess:
				state.status = .success
				return .send(.delegate(.sendPasswordResetSuccess(validEmail: state.email.value)))
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
				
			case let .updateEmail(updatedEmail):
				state.email = updatedEmail
				if let error = state.email.error as? EmailValidationError {
					state.emailValidationErrorMessage = error.errorDescription
				} else {
					state.emailValidationErrorMessage = nil
				}
			
				return .none
			}
		}
	}
}

public struct ForgotPasswordView: View {
	@Bindable var store: StoreOf<ForgotPasswordReducer>
	@FocusState var focus: ForgotPasswordReducer.State.Field?
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<ForgotPasswordReducer>) {
		self.store = store
	}
	public var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: AppSpacing.md) {
				Text("Email Veritication")
					.font(textTheme.headlineSmall.font)
					.foregroundStyle(Assets.Colors.bodyColor)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.top, AppSpacing.xxxlg * 3)
				AuthTextField(
					placeholder: "Email",
					errorMessage: store.emailValidationErrorMessage,
					isSecure: false,
					showSensitive: false,
					input: $store.emailInput.sending(\.updateEmailInput)
				)
				.focused($focus, equals: .email)
				AuthButton(
					isLoading: store.status == .loading,
					text: "Next",
					outlined: false,
					style: AppButtonStyle(
						foregroundColor: Assets.Colors.white,
						backgroundColor: Assets.Colors.blue,
						textStyle: textTheme.labelLarge,
						fullWidth: true
					)) {
						store.send(.onTapNextButton)
					}
					.disabled(store.nextButtonDisabled)
			}
			.padding(.horizontal, AppSpacing.xlg)
		}
		.toolbar(.hidden, for: .navigationBar)
		.safeAreaInset(edge: .top) {
			AppNavigationBar(title: "Password Recovery") {
				store.send(.delegate(.onTapBackButton))
			}
			.padding(.horizontal, AppSpacing.lg)
		}
		.bind($store.focus, to: $focus)
	}
}

#Preview {
	ForgotPasswordView(
		store: Store(
			initialState: ForgotPasswordReducer.State(),
			reducer: { ForgotPasswordReducer() }
		)
	)
}
