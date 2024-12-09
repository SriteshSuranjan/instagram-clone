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
import HomeFeature
import BottomBarVisiblePreference
import AppLoadingIndeterminateClient
import UploadTaskClient

@Reducer
public struct AppReducer {
	public init() {}

	@Reducer(state: .equatable)
	public enum View {
		case launch(LaunchReducer)
		case auth(AuthReducer)
		case home(HomeReducer)
	}

	@ObservableState
	public struct State: Equatable {
		var appDelegate: AppDelegateReducer.State
		var view: View.State
		var snackbarMessages: [SnackbarMessage] = []
		var showLoading = false
		public init(
			appDelegate: AppDelegateReducer.State = AppDelegateReducer.State(),
			destination: View.State? = nil
		) {
			self.appDelegate = appDelegate
			self.view = .launch(LaunchReducer.State())
		}
	}

	@Dependency(\.userClient.authClient) var authClient
	@Dependency(\.snackbarMessagesClient) var snackbarMessagesClient
	@Dependency(\.appLoadingIndeterminateClient) var appLoadingIndeterminateClient
	
	public enum Action: BindableAction {
		case appDelegate(AppDelegateReducer.Action)
		case authUserResponse(User)
		case binding(BindingAction<State>)
		case showSnackbarMessages([SnackbarMessage])
		case showAppLoading(Bool)
		case task
		case view(View.Action)
		case performUpLoadTask(UploadTask)
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
			Scope(state: \.home, action: \.home) {
				HomeReducer()
			}
		}
		Reduce { state, action in
			switch action {
			case let .authUserResponse(user):
				if user.isAnonymous {
					state.view = .auth(AuthReducer.State())
				} else {
					if case .home = state.view {
						
					} else {
						state.view = .home(HomeReducer.State(authenticatedUser: user))
					}
				}
				return .none
			case .binding:
				return .none
			case .task:
				return .run { @MainActor send in
					async let currentUser: Void = {
						for await user in authClient.user() {
							await send(.authUserResponse(user))
						}
					}()
					async let snackbarMessages: Void = {
						for await snackbarMessages in await snackbarMessagesClient.snackbarMessages() {
							await send(.showSnackbarMessages(snackbarMessages), animation: .bouncy)
						}
					}()
					
					async let appLoading: Void = {
						for await loading in await appLoadingIndeterminateClient.isLoading() {
							await send(.showAppLoading(loading), animation: .bouncy)
						}
					}()
					_ = await (currentUser, snackbarMessages, appLoading)
				}
			case .appDelegate:
				return .none
				
			case let .showSnackbarMessages(snackbarMessages):
				state.snackbarMessages = snackbarMessages
				return .none
			case let .showAppLoading(isLoading):
				state.showLoading = isLoading
				return .none

			case .view:
				return .none
			default: return .none
			}
		}
		UploadTaskReducer()
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
			case let .home(homeStore):
				NavigationStack {
					HomeView(store: homeStore)
				}
			}
		}
		.task { await store.send(.task).finish() }
		.snackbar(messages: $store.snackbarMessages)
		.appLoadintIndeterminate(presented: store.showLoading)
//		NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
//			Group {
//				switch store.scope(state: \.view, action: \.view).case {
//				case let .launch(launchStore):
//					LaunchView(store: launchStore)
//				case let .auth(authStore):
//					AuthView(store: authStore)
//				case let .home(homeStore):
//					HomeView(store: homeStore)
//				}
//			}
//			.task { await store.send(.task).finish() }
//			.snackbar(messages: $store.snackbarMessages)
//			.appLoadintIndeterminate(presented: store.showLoading)
//		} destination: { pathStore in
//			switch pathStore.case {
//			case let .userProfile(userProfileStore):
//				UserProfileView(store: userProfileStore)
//			}
//		}
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
