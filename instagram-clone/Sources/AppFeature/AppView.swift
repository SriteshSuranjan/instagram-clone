import AppUI
import AuthFeature
import ComposableArchitecture
import Env
import Foundation
import LaunchFeature
import SwiftUI
import UserClient
import Shared
import SnackbarMessagesClient

@Reducer
public struct AppReducer {
	public init() {}

	@Reducer(state: .equatable)
	public enum View {
		case launch(LaunchReducer)
		case auth(AuthReducer)
	}

	@ObservableState
	public struct State: Equatable {
		var appDelegate: AppDelegateReducer.State
		var view: View.State
		var snackbarMessages: [SnackbarMessage] = []
		public init(
			appDelegate: AppDelegateReducer.State = AppDelegateReducer.State(),
			destination: View.State? = nil
		) {
			self.appDelegate = appDelegate
			self.view = .auth(AuthReducer.State())
		}
	}

	@Dependency(\.userClient) var userClient
	@Dependency(\.snackbarMessagesClient) var snackbarMessagesClient
	
	public enum Action: BindableAction {
		case appDelegate(AppDelegateReducer.Action)
		case binding(BindingAction<State>)
		case showSnackbarMessages([SnackbarMessage])
		case task
		case loadAuth
		case view(View.Action)
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.appDelegate, action: \.appDelegate) {
			AppDelegateReducer()
		}
		Scope(state: \.view, action: \.view) {
			Scope(state: \.launch, action: \.launch) {
				LaunchReducer()
			}
			Scope(state: \.auth, action: \.auth) {
				AuthReducer()
			}
		}
		
		
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { @MainActor send in
					async let snackbarMessages: Void = {
						for await snackbarMessages in await snackbarMessagesClient.snackbarMessages() {
							await send(.showSnackbarMessages(snackbarMessages), animation: .bouncy)
						}
					}()
					_ = await snackbarMessages
				}
			case .appDelegate:
				return .none
				
			case let .showSnackbarMessages(snackbarMessages):
				state.snackbarMessages = snackbarMessages
				return .none

			case .view:
				return .none

			case .loadAuth:
				state.view = .auth(AuthReducer.State())
				return .none
			}
		}
	}
}

public struct AppView: View {
	@Bindable var store: StoreOf<AppReducer>
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<AppReducer>) {
		self.store = store
	}

	public var body: some View {
		Group {
			switch store.scope(state: \.view, action: \.view).case {
			case let .launch(launchStore):
				LaunchView(store: launchStore)
			case let .auth(authStore):
				AuthView(store: authStore)
			}
		}
		.task { await store.send(.task).finish() }
		.snackbar(messages: $store.snackbarMessages)
	}
}

#Preview {
	AppView(
		store: Store(
			initialState: AppReducer.State(),
			reducer: { AppReducer() }
		)
	)
}
