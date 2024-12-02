import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import InstagramBlocksUI
import Shared
import SnackbarMessagesClient

@Reducer
public struct SignUpReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var signUpForm = SignUpFormReducer.State()
		var status: SignUpSubmissionStatus = .idle
		var signUpButtonDisabled: Bool {
			status.isLoading
		}
		public init() {}
		
		public enum SignUpSubmissionStatus: Equatable {
			case idle
			case inProgress
			case success
			case emailAlreadyRegistered
			case networkError
			case error
			
			var isSuccess: Bool {
				self == .success
			}
			var isLoading: Bool {
				self == .inProgress
			}
			var isEmailAlreadyRegistered: Bool {
				self == .emailAlreadyRegistered
			}
			var isNetworkError: Bool {
				self == .networkError
			}
			var isError: Bool {
				self == .error
			}
		}
	}
	public enum Action {
		case actionSignUp(email: String, fullName: String, userName: String, password: String)
		case delegate(Delegate)
		case onTapSignUpButton
		case resignFocus
		case signUpForm(SignUpFormReducer.Action)
		case signUpResponse(Result<Void, AuthenticationError>)
		case task
		
		public enum Delegate {
			case onTapSignInIntoAccountButton
		}
	}
	
	@Dependency(\.userClient.authClient) var authClient
	@Dependency(\.snackbarMessagesClient) var snackbarMessagesClient
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.signUpForm, action: \.signUpForm) {
			SignUpFormReducer()
		}
		Reduce {
			state,
			action in
			switch action {
			case let .actionSignUp(email, fullName, userName, password):
				state.status = .inProgress
				return .run { send in
					try await authClient.signUpWithPassword(password: password, fullName: fullName, username: userName, avatarUrl: nil, email: email, phone: nil, pushToken: nil)
					await send(.signUpResponse(.success(())))
				} catch: {error, send in
					guard let signUpError = error as? AuthenticationError else {
						return
					}
					await send(.signUpResponse(.failure(signUpError)))
				}
			case .delegate:
				return .none
			case .onTapSignUpButton:
				return .run { [email = state.signUpForm.email, password = state.signUpForm.password, fullName = state.signUpForm.fullName, userName = state.signUpForm.userName] send in
					await send(.signUpForm(.emailDidEndEditing))
					await send(.signUpForm(.fullNameDidEndEditing))
					await send(.signUpForm(.userNameDidEndEditing))
					await send(.signUpForm(.passwordDidEndEditing))
					guard email.validated,
								password.validated,
								fullName.validated,
								userName.validated else {
						return
					}
					await send(.actionSignUp(email: email.value, fullName: fullName.value, userName: userName.value, password: password.value))
				}
			case .resignFocus:
				return .send(.signUpForm(.resignTextFieldFocus))
			case .signUpForm:
				return .none
			case let .signUpResponse(result):
				let signUpSubmissionStatus: State.SignUpSubmissionStatus
				switch result {
				case .success:
					signUpSubmissionStatus = .idle
					return .run { _ in
						await snackbarMessagesClient.show(
							SnackbarMessage.success(
								title: "Sign up successfully",
								backgroundColor: Assets.Colors.snackbarSuccessBackground
							)
						)
					}
				case let .failure(error):
					if let errorCode = error.errorCode,
						 errorCode == 400  {
						signUpSubmissionStatus = .emailAlreadyRegistered
					} else {
						signUpSubmissionStatus = .error
					}
					state.status = signUpSubmissionStatus
					return .run { [errorDescription = error.errorDescription] _ in
						await snackbarMessagesClient.show(
							SnackbarMessage.error(
								title: "Sign up failed",
								description: errorDescription,
								backgroundColor: Assets.Colors.snackbarErrorBackground
							)
						)
					}
				}
				
				
			case .task:
				return .none
			}
		}
	}
}

public struct SignUpView: View {
	@Bindable var store: StoreOf<SignUpReducer>
	public init(store: StoreOf<SignUpReducer>) {
		self.store = store
	}
	public var body: some View {
		ZStack(alignment: .bottom) {
			ScrollView(showsIndicators: false) {
				VStack {
					logoView()
					AvatarImagePicker { data, url in
						
					}
					SignUpForm(store: store.scope(state: \.signUpForm, action: \.signUpForm))
						.padding(.bottom, AppSpacing.xlg)
					AuthButton(
						isLoading: store.status.isLoading,
						text: "Sign Up") {
							store.send(.onTapSignUpButton)
						}
						.disabled(store.signUpButtonDisabled)
				}
			}
			VStack {
				Spacer()
				SignInIntoAccountButton {
					store.send(.delegate(.onTapSignInIntoAccountButton))
				}
			}
			.frame(maxWidth: .infinity)
			.ignoresSafeArea(.keyboard)
		}
		.scrollDismissesKeyboard(.automatic)
		.padding(.horizontal, AppSpacing.xlg)
		.toolbar(.hidden, for: .navigationBar)
		.task {
			await store.send(.task).finish()
		}
		.onTapGesture {
			store.send(.resignFocus)
		}
	}
	
	@ViewBuilder
	private func logoView() -> some View {
		AppLogoView(
			width: .infinity,
			height: 50,
			color: Assets.Colors.bodyColor,
			contentMode: .fit
		)
		.padding(.top, AppSpacing.xxxlg + AppSpacing.xlg)
	}
}

