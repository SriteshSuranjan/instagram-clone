import AppUI
import ComposableArchitecture
import Foundation
import Shared
import SwiftUI
import UserClient
import ValidatorClient
import SnackbarMessagesClient

@Reducer
public struct LoginReducer: Sendable {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var status: LoginSubmissionStatus = .idle
		var loginForm = LoginFormReducer.State()
		var signInButtonDisabled: Bool {
			let disabled = status.isLoading ||
			status.isGoogleAuthInProgress ||
			status.isGithubAuthInProgress
			return disabled
		}

		var googleSignInButtonDisabled: Bool {
			status == .loading ||
				status == .githubAuthInProgress ||
				status == .googleAuthInProgress
		}
		
		var githubSignInButtonDisabled: Bool {
			status == .loading ||
				status == .githubAuthInProgress ||
				status == .googleAuthInProgress
		}
		
		var googleSignInButtonIsLoading: Bool {
			status == .googleAuthInProgress
		}
		
		var githubSignInButtonIsLoading: Bool {
			status == .githubAuthInProgress
		}
		
		public init() {}
		
		public enum LoginSubmissionStatus: Equatable {
			case idle
			case loading
			case googleAuthInProgress
			case githubAuthInProgress
			case success
			case invalidCredentials
			case userNotFound
			case networkError
			case error
			case googleLogInFailure
			case githubLogInFailure
			
			var isSuccess: Bool {
				self == .success
			}
			
			var isLoading: Bool {
				self == .loading
			}
			
			var isGoogleAuthInProgress: Bool {
				self == .googleAuthInProgress
			}
			
			var isGithubAuthInProgress: Bool {
				self == .githubAuthInProgress
			}
			
			var isInvalidCredentials: Bool {
				self == .invalidCredentials
			}
			
			var isNetworkError: Bool {
				self == .networkError
			}
			
			var isUserNotFound: Bool {
				self == .userNotFound
			}
			
			var isError: Bool {
				self == .error ||
					isUserNotFound ||
					isNetworkError ||
					isInvalidCredentials
			}
		}
	}

	public enum Action: BindableAction {
		case actionPasswordLogin(email: String, password: String)
		case authProviderLogInFailed(error: AuthenticationError, provider: AuthProvider)
		case binding(BindingAction<State>)
		case delegate(Delegate)
		case logInFailed(AuthenticationError)
		case loginForm(LoginFormReducer.Action)
		case onTapSignInButton
		case onAuthUserChanged(User)
		case onTapAuthProviderButton(AuthProvider)
		case task
		case resignFocus
		
		case logout
		
		public enum Delegate {
			case onTapForgotPasswordButton
			case onTapSignUpButton
		}
	}

	@Dependency(\.userClient) var userClient
	@Dependency(\.snackbarMessagesClient) var snackbarMessagesClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.loginForm, action: \.loginForm) {
			LoginFormReducer()
		}
		Reduce {
			state,
				action in
			switch action {
			case let .actionPasswordLogin(email, password):
				state.status = .loading
				return .run { _ in
					try await userClient.logInWithPassword(password: password, email: email, phone: "")
					await snackbarMessagesClient.show(
						message: .success(
							title: "Log in Successfully",
							description: "You are now connected to Supabase",
							backgroundColor: Assets.Colors.snackbarSuccessBackground
						)
					)
				} catch: { error, send in
					guard let authenticationError = error as? AuthenticationError else {
						return
					}
					await send(.logInFailed(authenticationError))
				}
			case let .authProviderLogInFailed(error, provider):
				switch provider {
				case .google: state.status = .googleLogInFailure
				case .github: state.status = .githubLogInFailure
				}
				debugPrint(error)
				return .none
			case .binding:
				return .none
			case .delegate:
				return .none
			case .loginForm:
				return .none
			case .onTapSignInButton:
				return .run { [email = state.loginForm.email, password = state.loginForm.password] send in
					await send(.loginForm(.emailDidEndEditing))
					await send(.loginForm(.passwordDidEndEditing))
					guard email.validated, password.validated else {
						return
					}
					await send(.actionPasswordLogin(email: email.value, password: password.value))
				}
			case .task:
				return .run { send in
					for await user in userClient.user() {
						await send(.onAuthUserChanged(user))
					}
				}
			case let .onAuthUserChanged(user):
				state.status = .idle
				debugPrint(user)
				return .none
			case let .onTapAuthProviderButton(provider):
				switch provider {
				case .google:
					state.status = .googleAuthInProgress
				case .github:
					state.status = .githubAuthInProgress
				}
				return .run { [provider] _ in
					switch provider {
					case .google: try await userClient.logInWithGoogle()
					case .github: try await userClient.logInWithGithub()
					}
				} catch: { [provider] error, send in
					guard let authenticationError = error as? AuthenticationError else {
						return
					}
					await send(.authProviderLogInFailed(error: authenticationError, provider: provider))
				}
			case let .logInFailed(error):
				state.status = .idle
				// TODO: switch error condition
//				switch error {
//
//				}
				return .run { _ in
					await snackbarMessagesClient.show(
						message: .error(
							title: "Log in Failed",
							description: error.errorDescription,
							backgroundColor: Assets.Colors.snackbarErrorBackground
						)
					)
				}
			case .resignFocus:
				return .send(.loginForm(.resignTextFieldFocus))
				
			case .logout:
				return .run { _ in
					try await userClient.logOut()
				}
			}
		}
	}
}

public struct LoginView: View {
	@Bindable var store: StoreOf<LoginReducer>
	public init(store: StoreOf<LoginReducer>) {
		self.store = store
	}

	public var body: some View {
		ZStack(alignment: .bottom) {
			ScrollView(showsIndicators: false) {
				VStack {
					logoView()
					LoginForm(store: store.scope(state: \.loginForm, action: \.loginForm))
					ForgotPasswordButton {
						store.send(.delegate(.onTapForgotPasswordButton))
					}
						.frame(maxWidth: .infinity, alignment: .trailing)
					AuthButton(isLoading: store.status.isLoading, text: "Sign In") {
						store.send(.onTapSignInButton)
					}
					.disabled(store.signInButtonDisabled)
					.padding(.top, AppSpacing.xlg)
					
					OrDivider()
						.padding(.horizontal, AppSpacing.xxlg)
						.padding(.vertical, AppSpacing.md)
					AuthProviderSignInButton(
						provider: .google,
						isLoading: store.googleSignInButtonIsLoading
					) {
						store.send(.onTapAuthProviderButton(.google))
					}
					.disabled(store.googleSignInButtonDisabled)
					AuthProviderSignInButton(
						provider: .github,
						isLoading: store.githubSignInButtonIsLoading
					) {
						store.send(.onTapAuthProviderButton(.github))
					}
					.disabled(store.githubSignInButtonDisabled)
					
//					Button("Log out", role: .destructive) {
//						store.send(.logout)
//					}
//					.buttonStyle(.borderedProminent)
				}
			}
			VStack {
				Spacer() // 添加这个将按钮推到底部
				SignUpNewAccountButton {
					store.send(.delegate(.onTapSignUpButton))
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
		.padding(.top, AppSpacing.xxxlg * 2)
	}
}

#Preview {
	LoginView(
		store: Store(
			initialState: LoginReducer.State(),
			reducer: { LoginReducer() }
		)
	)
}
