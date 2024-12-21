import AppUI
import BottomBarVisiblePreference
import ComposableArchitecture
import FeedFeature
import Foundation
import ReelsFeature
import Shared
import SwiftUI
import TimelineFeature
import InstagramClient
import UserProfileFeature
import InstagramBlocksUI
import SnackbarMessagesClient

public enum HomeTab: Identifiable, Hashable, CaseIterable {
	case feed
	case timeline
	case reels
	case userProfile

	public var id: String {
		switch self {
		case .feed: return "feed"
		case .timeline: return "timeline"
		case .reels: return "reels"
		case .userProfile: return "userProfile"
		}
	}
}

typealias IconNavBarItemView = NavBarItemView<EmptyView>

extension NavBarItemView {
	static func feed() -> IconNavBarItemView { IconNavBarItemView(icon: .system("house.fill")) }
	static func timeline() -> IconNavBarItemView { IconNavBarItemView(icon: .system("magnifyingglass")) }
	static func reels() -> IconNavBarItemView { IconNavBarItemView(icon: .system("play.rectangle.on.rectangle.fill")) }
}

@Reducer
public struct HomeReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public var authenticatedUser: User
		var currentTab: HomeTab = .feed
		var showAppLoadingIndeterminate = false
		var feed: FeedReducer.State
		var timeline = TimelineReducer.State()
		var reels = ReelsReducer.State()
		var userProfile: UserProfileReducer.State
		public init(authenticatedUser: User) {
			self.userProfile = UserProfileReducer.State(authenticatedUserId: authenticatedUser.id, profileUserId: authenticatedUser.id)
			self.authenticatedUser = authenticatedUser
			self.feed = FeedReducer.State(profileUserId: authenticatedUser.id)
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case feed(FeedReducer.Action)
		case timeline(TimelineReducer.Action)
		case task
		case reels(ReelsReducer.Action)
		case authenticatedUserProfileUpdated(User)
		case userProfile(UserProfileReducer.Action)
		case updateAppLoadingIndeterminate(show: Bool)
		case onTapTab(HomeTab)
	}

	@Dependency(\.instagramClient.databaseClient) var databaseClient
	@Dependency(\.snackbarMessagesClient) var snackbarMessagesClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.feed, action: \.feed) {
			FeedReducer()
		}
		Scope(state: \.timeline, action: \.timeline) {
			TimelineReducer()
		}
		Scope(state: \.reels, action: \.reels) {
			ReelsReducer()
		}
		Scope(state: \.userProfile, action: \.userProfile) {
			UserProfileReducer()
		}
		Reduce { state, action in
			switch action {
			case let .authenticatedUserProfileUpdated(user):
				state.authenticatedUser = user
				return .none
			case .binding:
				return .none
			case .feed:
				return .none
			case .timeline:
				return .none
			case .task:
				return .run { [userId = state.authenticatedUser.id] send in
					async let authProfileUpdate: Void = {
						for await user in await databaseClient.profile(userId) {
							await send(.authenticatedUserProfileUpdated(user))
						}
					}()
					_ = await authProfileUpdate
				}
			case .reels:
				return .none
			case let .userProfile(.delegate(.routeToFeed(scrollToTop))):
				state.currentTab = .feed
				if scrollToTop {
					return .run { send in
						@Dependency(\.continuousClock) var clock
						try await clock.sleep(for: .milliseconds(200))
						await send(.feed(.scrollToTop), animation: .snappy)
					}
				}
				return .none
			case .userProfile:
				return .none
			case let .updateAppLoadingIndeterminate(show):
				guard state.showAppLoadingIndeterminate != show else {
					return .none
				}
				state.showAppLoadingIndeterminate = show
				return .none
			case let .onTapTab(tab):
				state.currentTab = tab
				return .run { _ in
//					await snackbarMessagesClient.show(message: .success(title: "Changed to tab \(tab)", backgroundColor: Assets.Colors.snackbarSuccessBackground))
				}
			}
		}
	}
}

public struct HomeView: View {
	@Bindable var store: StoreOf<HomeReducer>
	@Environment(\.textTheme) var textTheme
	@State private var currentTab: HomeTab = .feed
	public init(store: StoreOf<HomeReducer>) {
		self.store = store
	}

	public var body: some View {
		NavigationStack {
			ZStack(alignment: .bottom) {
				TabView(selection: $store.currentTab) {
					FeedView(store: store.scope(state: \.feed, action: \.feed))
						.tag(HomeTab.feed)
					TimelineView(store: store.scope(state: \.timeline, action: \.timeline))
						.tag(HomeTab.timeline)
					ReelsView(store: store.scope(state: \.reels, action: \.reels))
						.tag(HomeTab.reels)
					UserProfileView(store: store.scope(state: \.userProfile, action: \.userProfile))
						.tag(HomeTab.userProfile)
				}
				HStack {
					ForEach(HomeTab.allCases) { tab in
						Button {
							store.send(.onTapTab(tab))
						} label: {
							switch tab {
							case .feed:
								IconNavBarItemView.feed()
							case .timeline:
								IconNavBarItemView.timeline()
							case .reels:
								IconNavBarItemView.reels()
							case .userProfile:
								Group {
									UserProfileAvatar(userId: store.authenticatedUser.id, avatarUrl: store.authenticatedUser.avatarUrl, radius: 18, isLarge: false, onTap: { _ in
										store.send(.onTapTab(tab))
									})
								}
								.animation(.snappy, value: store.currentTab)
							}
						}
						.noneEffect()
						.foregroundStyle(store.currentTab == tab ? Assets.Colors.bodyColor : Color(.systemGray5))
						.frame(maxWidth: .infinity)
					}
				}
				.frame(height: 48)
				.background(Assets.Colors.appBarBackgroundColor)
			}
			.task {
				await store.send(.task).finish()
			}
			.toolbar(.hidden, for: .navigationBar)
		}
	}
}
