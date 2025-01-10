import AppUI
import BottomBarVisiblePreference
import ChatsFeature
import ComposableArchitecture
import CreatePostFeature
import FeedFeature
import Foundation
import InstagramBlocksUI
import InstagramClient
import MediaPickerFeature
import ReelsFeature
import Shared
import SnackbarMessagesClient
import SwiftUI
import TimelineFeature
import UserProfileFeature

public enum HomePageType: Hashable, CaseIterable, Identifiable {
	case mediaPicker
	case feedBody
	case chats
	public var id: String {
		switch self {
		case .mediaPicker: return "mediaPicker"
		case .feedBody: return "feedBody"
		case .chats: return "chats"
		}
	}
}

public enum HomeTab: Identifiable, Hashable, CaseIterable {
	case feed
	case timeline
	case quickAdd
	case reels
	case userProfile

	public var id: String {
		switch self {
		case .feed: return "feed"
		case .timeline: return "timeline"
		case .quickAdd: return "quickAdd"
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
	static func quickAdd() -> IconNavBarItemView { IconNavBarItemView(icon: .system("plus.rectangle")) }
}

@Reducer
public struct HomeReducer {
	public init() {}

	@Reducer(state: .equatable)
	public enum Destination {
		case createPost(CreatePostReducer)
	}

	@ObservableState
	public struct State: Equatable {
		public var authenticatedUser: User
		var currentTab: HomeTab = .feed
		var showAppLoadingIndeterminate = false
		var pageType: HomePageType? = .feedBody
		var feed: FeedReducer.State
		var timeline: TimelineReducer.State
		var reels: ReelsReducer.State
		var userProfile: UserProfileReducer.State
		var mediaPicker: MediaPickerReducer.State
		var chats: ChatsReducer.State
		@Presents var destination: Destination.State?
		public init(authenticatedUser: User) {
			self.userProfile = UserProfileReducer.State(authenticatedUserId: authenticatedUser.id, profileUserId: authenticatedUser.id)
			self.authenticatedUser = authenticatedUser
			self.feed = FeedReducer.State(profileUserId: authenticatedUser.id)
			self.mediaPicker = MediaPickerReducer.State(pickerConfiguration: MediaPickerView.Configuration(maxItems: 10, reels: false, showVideo: true))
			self.chats = ChatsReducer.State(authUser: authenticatedUser)
			self.reels = ReelsReducer.State(authorizedId: authenticatedUser.id)
			self.timeline = TimelineReducer.State(authorizedId: authenticatedUser.id)
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
		case mediaPicker(MediaPickerReducer.Action)
		case chats(ChatsReducer.Action)
		case destination(PresentationAction<Destination.Action>)
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
		Scope(state: \.mediaPicker, action: \.mediaPicker) {
			MediaPickerReducer()
		}
		Scope(state: \.chats, action: \.chats) {
			ChatsReducer()
		}
		Reduce { state, action in
			switch action {
			case let .authenticatedUserProfileUpdated(user):
				state.authenticatedUser = user
				return .none
			case .binding:
				return .none
			case .feed(.delegate(.onTapChatsButton)):
				state.pageType = .chats
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
				if tab == .quickAdd {
					state.currentTab = .feed
					state.pageType = .mediaPicker
				} else {
					state.currentTab = tab
				}
				return .none
			case .mediaPicker(.delegate(.onTapCancelButton)):
				state.pageType = .feedBody
				return .none
			case .mediaPicker(.delegate(.createPostPopToRoot)):
				state.pageType = .feedBody
				return .send(.feed(.scrollToTop), animation: .snappy)
			case .mediaPicker:
				return .none
			case .chats(.delegate(.onTapBackButton)):
				state.pageType = .feedBody
				return .none
			case .chats:
				return .none
			case .destination:
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
		}
	}
}

public struct HomeView: View {
	@Bindable var store: StoreOf<HomeReducer>
	@Environment(\.textTheme) var textTheme
	@State private var currentTab: HomeTab = .feed
	@Environment(\.statusBarHeight) var statusBarHeight
	public init(store: StoreOf<HomeReducer>) {
		self.store = store
	}

	public var body: some View {
		NavigationStack {
			GeometryReader { geometryReader in
				ScrollView(.horizontal) {
					LazyHStack(spacing: 0) {
						ForEach(HomePageType.allCases) { page in
							homePageView(page: page)
								.frame(width: geometryReader.size.width, height: geometryReader.size.height)
								.id(page)
						}
					}
					.scrollTargetLayout()
				}
				.scrollPosition(id: $store.pageType)
				.scrollIndicators(.hidden)
				.scrollTargetLayout()
				.scrollTargetBehavior(.paging)
				.scrollDisabled(store.currentTab != .feed)
				.animation(.default, value: store.pageType)
			}
			.task {
				await store.send(.task).finish()
			}
		}
	}

	@ViewBuilder
	private func homePageView(page: HomePageType) -> some View {
		switch page {
		case .mediaPicker: mediaPicker()
		case .feedBody: tabView()
		case .chats: chatsView()
		}
	}

	@ViewBuilder
	private func mediaPicker() -> some View {
		MediaPicker(store: store.scope(state: \.mediaPicker, action: \.mediaPicker))
	}

	@ViewBuilder
	private func chatsView() -> some View {
		ChatsView(store: store.scope(state: \.chats, action: \.chats))
	}

	@ViewBuilder
	private func tabView() -> some View {
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
			.padding(.top)
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
						case .quickAdd:
							IconNavBarItemView.quickAdd()
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
	}
}
