import Foundation
import SwiftUI
import ComposableArchitecture
import PostsListFeature
import InstaBlocks
import AppUI
import Shared
import InstagramClient

@Reducer
public struct UserProfilePostsReducer {
	public init() {}
	
	@Reducer(state: .equatable)
	public enum Destination {
		case userProfile(UserProfileReducer)
	}
	
	@ObservableState
	public struct State: Equatable {
		var profileUserId: String
		var scrollTo: String?
		var postsList: PostsListReducer.State
		@Presents var destination: Destination.State?
		public init(profileUserId: String, scrollTo: String? = nil) {
			self.profileUserId = profileUserId
			self.scrollTo = scrollTo
			self.postsList = PostsListReducer.State(scrollTo: nil, profileUserId: profileUserId)
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onTapBackButton
		case updatePostsOfUser([InstaBlockWrapper])
		case postsList(PostsListReducer.Action)
		case destination(PresentationAction<Destination.Action>)
		case task
	}
	
	@Dependency(\.instagramClient) var instagramClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.postsList, action: \.postsList) {
			PostsListReducer()
		}
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .onTapBackButton:
				return .run { _ in
					@Dependency(\.dismiss) var dismiss
					await dismiss()
				}
			case let .updatePostsOfUser(blocks):
				return .send(.postsList(.updateBlocks(blocks, scrollTo: state.scrollTo)), animation: .snappy)
			case .postsList:
				return .none
			case .destination:
				return .none
			case .task:
				return .run { [profileUserId = state.profileUserId] send in
					await postsOfUser(send: send, userId: profileUserId)
				}
				.cancellable(id: "PostsOfUser", cancelInFlight: true)
			}
		}
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
		}
	}
	
	private func postsOfUser(send: Send<Action>, userId: String) async {
		async let posts: Void = {
			for await posts in await instagramClient.databaseClient.postsOf(userId) {
				await send(.updatePostsOfUser(posts.map { InstaBlockWrapper.postLarge($0.toPostLargeBlock()) }))
			}
		}()
		_ = await posts
	}
}

public struct UserProfilePostsView: View {
	@Bindable var store: StoreOf<UserProfilePostsReducer>
	public init(store: StoreOf<UserProfilePostsReducer>) {
		self.store = store
	}
	public var body: some View {
		VStack(spacing: 0) {
			appBar()
			PostsListView(store: store.scope(state: \.postsList, action: \.postsList))
		}
		.navigationDestination(
			item: $store.scope(
				state: \.destination?.userProfile,
				action: \.destination.userProfile
			)
		) { userProfileStore in
			UserProfileView(store: userProfileStore)
		}
		.task {
			await store.send(.task).finish()
		}
		
		.toolbar(.hidden, for: .navigationBar)
	}
	
	@ViewBuilder
	private func appBar() -> some View {
		AppNavigationBar(title: "Posts") {
			store.send(.onTapBackButton)
		}
		.padding(.horizontal, AppSpacing.lg)
		.padding(.bottom, AppSpacing.sm)
	}
}
