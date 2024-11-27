import SwiftUI
import ComposableArchitecture

@Reducer
public struct AuthReducer {
	public init() {}
	
	@Reducer(state: .equatable)
	public enum Path {
		case signUp(SignUpReducer)
		case forgotPassword(ForgotPasswordReducer)
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
				._printChanges()
		}
		Reduce { state, action in
			switch action {
			case .logIn:
				return .none
			case .task:
				return .none
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
			}
		}

	}
}
