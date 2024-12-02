import ComposableArchitecture
import SwiftUI

@Reducer
public struct AuthReducer {
	public init() {}

	@Reducer(state: .equatable)
	public enum Path {
		case signUp(SignUpReducer)
		case forgotPassword(ForgotPasswordReducer)
		case changePassword(ChangePasswordReducer)
	}

	@ObservableState
	public struct State: Equatable {
		var logIn = LoginReducer.State()
		var paths = StackState<Path.State>()
		public init() {}
	}

	public enum Action {
		case logIn(LoginReducer.Action)
		case task
		case paths(StackAction<Path.State, Path.Action>)
	}

	public var body: some ReducerOf<Self> {
		Scope(state: \.logIn, action: \.logIn) {
			LoginReducer()
		}
		Reduce { state, action in
			switch action {
			case .logIn(.delegate(.onTapForgotPasswordButton)):
				state.paths.append(.forgotPassword(ForgotPasswordReducer.State()))
				return .none
			case .logIn(.delegate(.onTapSignUpButton)):
				state.paths.append(.signUp(SignUpReducer.State()))
				debugPrint(state.paths.ids)
				return .none
			case .logIn:
				return .none
			case .task:
				return .none
			case let .paths(.element(id, subAction)):
				switch subAction {
				case .signUp(.delegate(.onTapSignInIntoAccountButton)):
					state.paths.pop(from: id)
					return .none
				case .forgotPassword(.delegate(.onTapBackButton)):
					state.paths.pop(from: id)
					return .none
				case .changePassword(.delegate(.onTapBackButton)):
					state.paths.removeAll()
					return .none
				case let .forgotPassword(.delegate(.sendPasswordResetSuccess(validEmail))):
					state.paths.append(.changePassword(ChangePasswordReducer.State(email: validEmail)))
					return .none
				default: return .none
				}
			case .paths:
				return .none
			}
		}
		.forEach(\.paths, action: \.paths)
	}
}

public struct AuthView: View {
	@Bindable var store: StoreOf<AuthReducer>
	public init(store: StoreOf<AuthReducer>) {
		self.store = store
	}

	public var body: some View {
		NavigationStack(
			path: $store.scope(state: \.paths, action: \.paths)
		) {
			LoginView(store: store.scope(state: \.logIn, action: \.logIn))
		} destination: { store in
			switch store.case {
			case let .signUp(signUpStore):
				SignUpView(store: signUpStore)
			case let .forgotPassword(forgotPasswordStore):
				ForgotPasswordView(store: forgotPasswordStore)
			case let .changePassword(changePasswordStore):
				ChangePasswordView(store: changePasswordStore)
			}
		}
	}
}
