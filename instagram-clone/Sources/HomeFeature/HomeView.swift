import AppUI
import ComposableArchitecture
import FeedFeature
import Foundation
import ReelsFeature
import Shared
import SwiftUI
import TimelineFeature
import UserProfileFeature

public enum Tab: Identifiable, Hashable {
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
		var currentTab: Tab = .feed
		var feed = FeedReducer.State()
		var timeline = TimelineReducer.State()
		var reels = ReelsReducer.State()
		var userProfile = UserProfileReducer.State()
		public init(authenticatedUser: User) {
			self.authenticatedUser = authenticatedUser
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case feed(FeedReducer.Action)
		case timeline(TimelineReducer.Action)
		case reels(ReelsReducer.Action)
		case userProfile(UserProfileReducer.Action)
	}

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
		Reduce { _, action in
			switch action {
			case .binding:
				return .none
			case .feed:
				return .none
			case .timeline:
				return .none
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
	public init(store: StoreOf<HomeReducer>) {
		self.store = store
	}

	public var body: some View {
		TabView(selection: $store.currentTab) {
			FeedView(store: store.scope(state: \.feed, action: \.feed))
				.tabItem {
					IconNavBarItemView.feed()
				}
				.tag(Tab.feed)
			TimelineView(store: store.scope(state: \.timeline, action: \.timeline))
				.tabItem {
					IconNavBarItemView.timeline()
				}
				.tag(Tab.timeline)
			ReelsView(store: store.scope(state: \.reels, action: \.reels))
				.tabItem {
					IconNavBarItemView.reels()
				}
				.tag(Tab.reels)
			UserProfileView(store: store.scope(state: \.userProfile, action: \.userProfile))
				.tabItem {
					NavBarItemView {
						Image(systemName: "person.fill")
							.resizable()
							.frame(width: 28, height: 28)
					}
				}
				.tag(Tab.userProfile)
		}
		.tint(Assets.Colors.bodyColor)
	}
}
