import Foundation
import Shared
import AppUI
import SwiftUI
import ComposableArchitecture
import InstaBlocks
import InstagramBlocksUI
import InstagramClient

@Reducer
public struct RepliedCommentsReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var comment: Comment
		var post: InstaBlockWrapper
		var currentUserId: String
		var repliedComments: IdentifiedArrayOf<CommentReducer.State> = []
		public init(comment: Comment, post: InstaBlockWrapper, currentUserId: String) {
			self.comment = comment
			self.post = post
			self.currentUserId = currentUserId
		}
	}
	public indirect enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case repliedComments(IdentifiedActionOf<CommentReducer>)
		case repliedCommentsUpdate([Comment])
		case delegate(Delegate)
		
		public enum Delegate {
			case onTapCommentReply(Comment)
		}
	}
	
	@Dependency(\.instagramClient.databaseClient) var databaseClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
			action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [comment = state.comment, post = state.post] send in
					await subscription(send: send, comment: comment, post: post)
				}
			case let .repliedComments(.element(_, subAction)):
				switch subAction {
				case let .userComment(.delegate(.onTapReplyButton(comment))):
					return .send(.delegate(.onTapCommentReply(comment)), animation: .easeInOut)
				default: return .none
				}
			case .repliedComments:
				return .none
			case let .repliedCommentsUpdate(comments):
				for comment in comments {
					if state.repliedComments[id: comment.id] == nil {
						state.repliedComments.append(
							CommentReducer.State(
								comment: comment,
								currentUserId: state.currentUserId,
								post: state.post,
								isReplied: true
							)
						)
					}
				}
				var removeCommentIds: [String] = []
				let commentIds = comments.map(\.id)
				for commentId in state.repliedComments.ids {
					if !commentIds.contains(commentId) {
						removeCommentIds.append(commentId)
					}
				}
				state.repliedComments.removeAll(where: { removeCommentIds.contains($0.id) })
				return .none
			case .delegate:
				return .none
			}
		}
		.forEach(\.repliedComments, action: \.repliedComments) {
			CommentReducer()
		}
	}
	
	private func subscription(send: Send<Action>, comment: Comment, post: InstaBlockWrapper) async {
		async let repliedComments: Void = {
			for await repliedComments in await databaseClient.repliedCommentsOf(comment.id) {
				await send(.repliedCommentsUpdate(repliedComments))
			}
		}()
		_ = await repliedComments
	}
}

public struct RepliedCommentsView: View {
	let store: StoreOf<RepliedCommentsReducer>
	public init(store: StoreOf<RepliedCommentsReducer>) {
		self.store = store
	}
	public var body: some View {
		LazyVStack {
			ForEach(store.scope(state: \.repliedComments, action: \.repliedComments)) { commentStore in
				CommentView(store: commentStore)
			}
		}
		.task {
			await store.send(.task).finish()
		}
	}
}
