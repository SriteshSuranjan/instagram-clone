import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import Shared
import InstagramClient
import InstagramBlocksUI

@Reducer
public struct CommentTextInputReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var userId: String
		var user: User?
		var content: String = ""
		public init(userId: String) {
			self.userId = userId
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case userProfileUpdated(User)
		case appendCommentInput(String)
		case task
		case onTapPublishCommentButton
		case delegate(Delegate)
		
		public enum Delegate {
			case onTapPublishCommentButton(String)
		}
	}
	
	@Dependency(\.instagramClient.databaseClient) var databaseClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [userId = state.userId] send in
					await subscriptions(send: send, userId: userId)
				}
			case let .userProfileUpdated(user):
				state.user = user
				return .none
			case let .appendCommentInput(text):
				state.content.append(text)
				return .none
			case .onTapPublishCommentButton:
				let commentContent = state.content.trimmingCharacters(in: .whitespacesAndNewlines)
				state.content = ""
				return .send(.delegate(.onTapPublishCommentButton(commentContent)))
			case .delegate:
				return .none
			}
		}
	}
	
	private func subscriptions(send: Send<Action>, userId: String) async {
		async let userInfo: Void = {
			for await profileUser in await databaseClient.profile(userId) {
				await send(.userProfileUpdated(profileUser))
			}
		}()
		_ = await userInfo
	}
}

public struct CommentTextInputView: View {
	@Bindable var store: StoreOf<CommentTextInputReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<CommentTextInputReducer>) {
		self.store = store
	}
	public var body: some View {
		HStack {
			UserProfileAvatar(
				userId: store.userId,
				avatarUrl: store.user?.avatarUrl,
				radius: 16
			)
			TextField("Add a comment", text: $store.content)
				.lineLimit(1)
				.font(textTheme.bodyLarge.font)
				.fontWeight(.semibold)
				.textFieldStyle(.plain)
				.tint(Assets.Colors.bodyColor)
			Spacer()
			if !store.content.isEmpty {
				Button("Publish") {
					store.send(.onTapPublishCommentButton)
				}
			}
		}
		.task {
			await store.send(.task).finish()
		}
	}
}
