import AppUI
import ComposableArchitecture
import Foundation
import Shared
import SwiftUI
import ValidatorClient
import UserClient

@Reducer
public struct LoginReducer: Sendable {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var status: LoginSubmissionStatus = .idle
		var loginForm = LoginFormReducer.State()
		var signInButtonDisabled: Bool {
			let disabled  = status != .idle ||
			loginForm.email.invalid ||
			loginForm.password.invalid
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
		case logInFailed(AuthenticationError)
		case binding(BindingAction<State>)
		case loginForm(LoginFormReducer.Action)
		case onTapSignInButton
		case onAuthUserChanged(User)
		case onTapAuthProviderButton(AuthProvider)
		case task
		case resignFocus
		
		case logout
	}

	@Dependency(\.userClient) var userClient
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.loginForm, action: \.loginForm) {
			LoginFormReducer()
		}
		BindingReducer()
		Reduce {
			state,
			action in
			switch action {
			case let .actionPasswordLogin(email, password):
				state.status = .loading
				return .run { send in
					try await userClient.logInWithPassword(password: password, email: email, phone: "")
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
			case .loginForm:
				return .none
			case .onTapSignInButton:
				return Effect.concatenate(
					.send(.loginForm(.resignTextFieldFocus)),
					.run { [email = state.loginForm.email, password = state.loginForm.password] send in
						guard email.validated && password.validated else {
							return
						}
						await send(.actionPasswordLogin(email: email.value, password: password.value))
					}
				)
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
				return .run { [provider] send in
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
				return .none
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
		VStack {
			ScrollView {
				logoView()
				LoginForm(store: store.scope(state: \.loginForm, action: \.loginForm))
				ForgotPasswordButton {
					
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
				SignInButton(isLoading: store.status.isLoading) {
					store.send(.onTapSignInButton)
				}
				.disabled(store.signInButtonDisabled)
				.padding(.top, AppSpacing.xlg)
				
				OrDivider()
					.padding(.horizontal, AppSpacing.md)
				AuthProviderSignInButton(
					provider: .google,
					isLoading: store.googleSignInButtonIsLoading) {
						store.send(.onTapAuthProviderButton(.google))
					}
					.disabled(store.googleSignInButtonDisabled)
					.padding(.bottom, AppSpacing.md)
				AuthProviderSignInButton(
					provider: .github,
					isLoading: store.githubSignInButtonIsLoading) {
						store.send(.onTapAuthProviderButton(.github))
					}
					.disabled(store.githubSignInButtonDisabled)
				
				Button("Log out", role: .destructive) {
					store.send(.logout)
				}
				.buttonStyle(.borderedProminent)
			}
		}
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
