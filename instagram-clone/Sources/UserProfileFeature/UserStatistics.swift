import AppUI
import ComposableArchitecture
import DatabaseClient
import Foundation
import Shared
import SwiftUI
import InstagramClient

public enum UserStatisticsTab: Int, Hashable {
	case followers = 1
	case followings = 2
}

@Reducer
public struct UserStatisticsReducer {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		var authUserId: String
		var user: User
		var followersCount: Int = 0
		var followingsCount: Int = 0
		var selectedTab: UserStatisticsTab
		var followersList: UserProfileListReducer.State
		var followingsList: UserProfileListReducer.State
		@Presents var userProfile: UserProfileReducer.State?
		public init(authUserId: String, user: User, selectedTab: UserStatisticsTab) {
			self.authUserId = authUserId
			self.user = user
			self.selectedTab = selectedTab
			self.followersList = .init(profileUser: user, follower: true)
			self.followingsList = .init(profileUser: user, follower: false)
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case userProfileUpdated(User)
		case followersCountUpdated(Int)
		case followingsCountUpdated(Int)
		case task
		case followersList(UserProfileListReducer.Action)
		case followingsList(UserProfileListReducer.Action)
		case updateSelectedTab(UserStatisticsTab)
		case userProfile(PresentationAction<UserProfileReducer.Action>)
	}

	private enum Cancel: Hashable {
		case profileSubscription
		case followersCountAndFollowingsCountSubscription
		case fetchFollowings
		case followersSubscription
	}
	
	@Dependency(\.instagramClient.databaseClient) var databaseClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.followersList, action: \.followersList) {
			UserProfileListReducer()
		}
		Scope(state: \.followingsList, action: \.followingsList) {
			UserProfileListReducer()
		}
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [userId = state.user.id] send in
					await withTaskGroup(of: Void.self) { group in
						group.addTask {
							await subscribeUserProfile(send: send, userId: userId)
						}
						group.addTask {
							await subscribeUserFollowersCountAndFollowingsCount(send: send, userId: userId)
						}
					}
				}
			case let .userProfileUpdated(user):
				state.user = user
				return .none
			case let .followersCountUpdated(followersCount):
				state.followersCount = followersCount
				return .none
			case let .followingsCountUpdated(followingsCount):
				state.followingsCount = followingsCount
				return .none
			case let .followersList(.delegate(.pushToUserProfile(profileUserId))):
				state.userProfile = UserProfileReducer.State(authenticatedUserId: state.authUserId, profileUserId: profileUserId, showBackButton: true)
				return .none
			case let .followingsList(.delegate(.pushToUserProfile(profileUserId))):
				state.userProfile = UserProfileReducer.State(authenticatedUserId: state.authUserId, profileUserId: profileUserId, showBackButton: true)
				return .none
			case .followersList:
				return .none
			case .followingsList:
				return .none
			case let .updateSelectedTab(tab):
				state.selectedTab = tab
				return .none
			case .userProfile:
				return .none
			}
		}
		.ifLet(\.$userProfile, action: \.userProfile) {
			UserProfileReducer()
		}
		
	}
	
	private func subscribeUserProfile(send: Send<Action>, userId: String) async {
		await withTaskCancellation(id: Cancel.profileSubscription, cancelInFlight: true) {
			for await userProfile in await databaseClient.profile(userId) {
				await send(.userProfileUpdated(userProfile))
			}
		}
	}
	
	private func subscribeUserFollowersCountAndFollowingsCount(send: Send<Action>, userId: String) async {
		await withTaskCancellation(id: Cancel.followersCountAndFollowingsCountSubscription, cancelInFlight: true) {
			async let followersCount: Void = {
				for await followersCount in await databaseClient.followersCount(userId: userId) {
					await send(.followersCountUpdated(followersCount))
				}
			}()
			async let followingsCount: Void = {
				for await followingsCount in await databaseClient.followingsCount(userId: userId) {
					await send(.followingsCountUpdated(followingsCount))
				}
			}()
			_ = await (followersCount, followingsCount)
		}
	}
}

public struct UserStatisticsView: View {
	@Bindable var store: StoreOf<UserStatisticsReducer>
	@State private var mainViewScrollState: UserStatisticsTab?
	@Environment(\.textTheme) var textTheme
	@Environment(\.dismiss) var dismiss
	public init(store: StoreOf<UserStatisticsReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack {
			AppNavigationBar(title: store.user.displayFullName) {
				dismiss()
			}
			.padding(.horizontal, AppSpacing.lg)
			GeometryReader { geometryReader in
				ScrollView {
					LazyVStack(pinnedViews: [.sectionHeaders]) {
						Section {
							Color.clear.frame(height: 25)
							ScrollView(.horizontal) {
								LazyHStack(spacing: 0) {
									UserProfileListView(store: store.scope(state: \.followersList, action: \.followersList))
										.id(UserStatisticsTab.followers)
										.frame(width: geometryReader.size.width, height: geometryReader.size.height)
									//
									UserProfileListView(store: store.scope(state: \.followingsList, action: \.followingsList))
										.id(UserStatisticsTab.followings)
										.frame(width: geometryReader.size.width, height: geometryReader.size.height)
									
								}
								.scrollTargetLayout()
							}
							.scrollPosition(
								id: Binding(
									get: { store.selectedTab },
									set: { newValue in
										store.send(.updateSelectedTab(newValue!))
									}
								)
							)
							.scrollTargetLayout()
							.scrollIndicators(.hidden)
							.scrollTargetBehavior(.paging)
							.frame(width: geometryReader.size.width, height: geometryReader.size.height)
							
						} header: {
							ScrollTabBarView(selection: $store.selectedTab.sending(\.updateSelectedTab)) {
								AppUI.TabItem(UserStatisticsTab.followers) {
									Text("\(store.followersCount) followers")
								}
								AppUI.TabItem(UserStatisticsTab.followings) {
									Text("\(store.followingsCount) followings")
								}
							}
							.font(textTheme.bodyLarge.font)
							.foregroundStyle(Assets.Colors.bodyColor)
						}
					}
				}
			}
		}
		.ignoresSafeArea(.all, edges: .bottom)
		.toolbar(.hidden, for: .navigationBar)
		.navigationDestination(item: $store.scope(state: \.userProfile, action: \.userProfile)) { userProfileStore in
			UserProfileView(store: userProfileStore)
		}
		.task {
			await store.send(.task).finish()
		}

	}
}
