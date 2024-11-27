import AppUI
import AuthFeature
import ComposableArchitecture
import Env
import Foundation
import SwiftUI
import LaunchFeature
import UserClient

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
		public init(
			appDelegate: AppDelegateReducer.State = AppDelegateReducer.State(),
			destination: View.State? = nil
		) {
			self.appDelegate = appDelegate
			self.view = .launch(LaunchReducer.State())
		}
	}

	@Dependency(\.userClient) var userClient
	
	public enum Action {
		case appDelegate(AppDelegateReducer.Action)
		case task
		case loadAuth
		case view(View.Action)
	}
	
	public var body: some ReducerOf<Self> {
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
			case .task:
				return .run { send in
					@Dependency(\.continuousClock) var clock
					try await clock.sleep(for: .seconds(2))
					await send(.loadAuth)
				}
			case .appDelegate:
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
