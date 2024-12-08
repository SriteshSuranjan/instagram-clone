import ComposableArchitecture
import Foundation
import Shared
import SwiftUI
import UserClient

@Reducer
public struct UserProfileListReducer {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		var profileUser: User
		var follower: Bool
		var userTiles: IdentifiedArrayOf<UserProfileListTileReducer.State> = []
		@Presents var removeFollowerAlert: AlertState<Action.Alert>?
		public init(profileUser: User, follower: Bool) {
			self.profileUser = profileUser
			self.follower = follower
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case usersUpdated([User], authUserId: String)
		case task
		case userTiles(IdentifiedActionOf<UserProfileListTileReducer>)
		case alert(PresentationAction<Alert>)
		case delegate(Delegate)
		public enum Alert: Equatable {
			case confirmRemoveFollower(userId: String)
		}
		public enum Delegate {
			case pushToUserProfile(userId: String)
		}
	}
	
	@Dependency(\.userClient.databaseClient) var databaseClient
	
	enum Cancel {
		case subscriptions
	}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
				action in
			switch action {
			case let .alert(.presented(.confirmRemoveFollower(userId))):
				return .run { _ in
					try await databaseClient.removeFollower(userId)
				}
			case .alert:
				return .none
			case .binding:
				return .none
			case .task:
				let follower = state.follower
				return .run { [userId = state.profileUser.id] send in
					await withTaskCancellation(id: Cancel.subscriptions, cancelInFlight: true) {
						if follower {
							await subscribeFollowers(send: send, userId: userId)
						} else {
							await getFollowings(send: send, userId: userId)
						}
					}
				}
			case let .usersUpdated(users, authUserId):
				for updateUser in users {
					if state.userTiles[id: updateUser.id] != nil {
						continue
					}
					state.userTiles.insert(UserProfileListTileReducer.State(
						profileUserId: state.profileUser.id,
						authUserId: authUserId,
						user: updateUser,
						follower: state.follower
					), at: 0)
				}
				
				let updateUserIds = users.map(\.id)
				var removalIds: [String] = []
				for userId in state.userTiles.map(\.id) {
					if !updateUserIds.contains(userId) {
						removalIds.append(userId)
					}
				}
				state.userTiles.removeAll(where: { removalIds.contains($0.id) })
				return .none
			case let .userTiles(.element(id, subAction)):
				switch subAction {
				case .delegate(.onRemoveFollowerAction):
					state.removeFollowerAlert = AlertState(
						title: {
							TextState("Remove follower")
						},
						actions: {
							ButtonState(role: .cancel) {
								TextState("Cancel")
							}
							ButtonState(role: .destructive, action: .send(.confirmRemoveFollower(userId: id))) {
								TextState("Remove")
							}
						},
						message: {
							TextState("Are you sure want to remove this follower?")
						}
					)
					return .none
				default: return .none
				}
				
			case .userTiles:
				return .none
			case .delegate:
				return .none
			}
		}
		.forEach(\.userTiles, action: \.userTiles) {
			UserProfileListTileReducer()
		}
		.ifLet(\.$removeFollowerAlert, action: \.alert)
	}
	
	private func subscribeFollowers(send: Send<Action>, userId: String) async {
		let authUserId = await databaseClient.currentUserId()
		for await followers in await databaseClient.followers(userId) {
			await send(.usersUpdated(followers, authUserId: authUserId), animation: .snappy)
		}
	}
	
	private func getFollowings(send: Send<Action>, userId: String) async {
		do {
			let authUserId = await databaseClient.currentUserId()
			let followings = try await databaseClient.followings(userId)
			await send(.usersUpdated(followings, authUserId: authUserId), animation: .snappy)
		} catch {
			debugPrint(error)
		}
	}
}

public struct UserProfileListView: View {
	@Bindable var store: StoreOf<UserProfileListReducer>
	public init(store: StoreOf<UserProfileListReducer>) {
		self.store = store
	}

	public var body: some View {
		List {
			ForEachStore(store.scope(state: \.userTiles, action: \.userTiles)) { userTileStore in
				Button {
					store.send(.delegate(.pushToUserProfile(userId: userTileStore.user.id)))
				} label: {
					UserProfileListTileView(store: userTileStore)
						.contentShape(.rect)
				}
				.fadeEffect()
			}
		}
		.listStyle(.plain)
		.task {
			await store.send(.task).finish()
		}
		.alert($store.scope(state: \.removeFollowerAlert, action: \.alert))
	}
}
