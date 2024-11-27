import AppUI
import ComposableArchitecture
import Foundation
import Shared
import SwiftUI
import ValidatorClient

@Reducer
public struct LoginReducer: Sendable {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var signInButtonDisabled = true
		var loginForm = LoginFormReducer.State()
		public init() {}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case loginForm(LoginFormReducer.Action)
		case resignFocus
	}

	public var body: some ReducerOf<Self> {
		Scope(state: \.loginForm, action: \.loginForm) {
			LoginFormReducer()
		}
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .loginForm:
				return .none
			case .resignFocus:
				return .send(.loginForm(.resignTextFieldFocus))
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
				SignInButton(isLoading: false) {
					
				}
				.padding(.top, AppSpacing.xlg)
			}
		}
		.toolbar(.hidden, for: .navigationBar)
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
