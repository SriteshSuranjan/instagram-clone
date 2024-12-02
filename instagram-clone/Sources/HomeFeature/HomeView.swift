import AppUI
import ComposableArchitecture
import FeedFeature
import Foundation
import ReelsFeature
import Shared
import SwiftUI
import TimelineFeature
import UserProfileFeature
import UserClient

public enum HomeTab: Identifiable, Hashable {
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
		var authenticatedUser: User
		var currentTab: HomeTab = .feed
		var feed = FeedReducer.State()
		var timeline = TimelineReducer.State()
		var reels = ReelsReducer.State()
		var userProfile: UserProfileReducer.State
		public init(authenticatedUser: User) {
			self.authenticatedUser = authenticatedUser
			self.userProfile = UserProfileReducer.State(authenticatedUserId: authenticatedUser.id, profileUserId: authenticatedUser.id)
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
	}
	
	@Dependency(\.userClient.databaseClient) var databaseClient

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
				._printChanges()
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
					for await user in await databaseClient.profile(userId) {
						await send(.authenticatedUserProfileUpdated(user))
					}
				}
			case .reels:
				return .none
			case .userProfile:
				return .none
			}
		}
	}
}

public struct HomeView: View {
	@Bindable var store: StoreOf<HomeReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<HomeReducer>) {
		self.store = store
	}

	public var body: some View {
		TabView(selection: $store.currentTab) {
			FeedView(store: store.scope(state: \.feed, action: \.feed))
				.tabItem {
					IconNavBarItemView.feed()
				}
				.tag(HomeTab.feed)
			TimelineView(store: store.scope(state: \.timeline, action: \.timeline))
				.tabItem {
					IconNavBarItemView.timeline()
				}
				.tag(HomeTab.timeline)
			ReelsView(store: store.scope(state: \.reels, action: \.reels))
				.tabItem {
					IconNavBarItemView.reels()
				}
				.tag(HomeTab.reels)

			UserProfileView(store: store.scope(state: \.userProfile, action: \.userProfile))
				.tabItem {
					Label(
						title: { Text(store.authenticatedUser.avatarName, format: .name(style: .abbreviated)) },
						icon: { Image(systemName: "person.circle") }
					)
				}
				.tag(HomeTab.userProfile)
				.task {
					await store.send(.task).finish()
				}
		}
		.tint(Assets.Colors.bodyColor)
	}
}
