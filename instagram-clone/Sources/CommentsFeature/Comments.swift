import Foundation
import Shared
import AppUI
import SwiftUI
import ComposableArchitecture
import InstaBlocks
import InstagramClient

@Reducer
public struct CommentsReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var post: InstaBlockWrapper
		var currentUserId: String
		var comments: IdentifiedArrayOf<CommentReducer.State> = []
		public init(post: InstaBlockWrapper, currentUserId: String) {
			self.post = post
			self.currentUserId = currentUserId
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case comments(IdentifiedActionOf<CommentReducer>)
		case commentsUpdate([Comment])
		case task
	}
	
	@Dependency(\.instagramClient.databaseClient) var databaseClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .comments:
				return .none
			case .task:
				return .run { [postId = state.post.id] send in
					for await comments in await databaseClient.commentsOf(postId) {
						await send(.commentsUpdate(comments), animation: .snappy)
					}
				}
			case let .commentsUpdate(comments):
				for comment in comments {
					if state.comments[id: comment.id] == nil {
						state.comments.append(CommentReducer.State(comment: comment, currentUserId: state.currentUserId, post: state.post))
					}
				}
				var removeCommentIds: [String] = []
				let commentIds = comments.map(\.id)
				for commentId in state.comments.ids {
					if !commentIds.contains(commentId) {
						removeCommentIds.append(commentId)
					}
				}
				state.comments.removeAll(where: { removeCommentIds.contains($0.id) })
				return .none
			}
		}
		.forEach(\.comments, action: \.comments) {
			CommentReducer()
		}
	}
}

public struct CommentsView: View {
	@Bindable var store: StoreOf<CommentsReducer>
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<CommentsReducer>) {
		self.store = store
	}
	public var body: some View {
		ScrollView(.vertical) {
			Text("Comments")
				.font(textTheme.titleLarge.font)
				.bold()
				.foregroundStyle(Assets.Colors.gray)
				.frame(maxWidth: .infinity, alignment: .center)
			LazyVStack {
				ForEach(store.scope(state: \.comments, action: \.comments)) { commentStore in
					CommentView(store: commentStore)
				}
			}
		}
		.scrollIndicators(.hidden)
		.task {
			await store.send(.task).finish()
		}
		.padding(.top, 40)
		.padding(.horizontal)
	}
}
