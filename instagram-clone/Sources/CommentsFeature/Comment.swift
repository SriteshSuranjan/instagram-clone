import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import Shared
import SwiftUI
import InstagramClient

@Reducer
public struct CommentReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable, Identifiable {
		var comment: Comment
		var currentUserId: String
		var post: InstaBlockWrapper
		var isReplied: Bool
		var userComment: UserCommentReducer.State
		var repliedComments: RepliedCommentsReducer.State?
		public init(
			comment: Comment,
			currentUserId: String,
			post: InstaBlockWrapper,
			isReplied: Bool = false
		) {
			self.comment = comment
			self.currentUserId = currentUserId
			self.post = post
			self.isReplied = isReplied
			self.userComment = UserCommentReducer.State(
				comment: comment,
				currentUserId: currentUserId,
				post: post,
				isReplied: isReplied,
				isLiked: false,
				isLikedByOwner: false,
				likesCount: 0
			)
			if !isReplied {
				self.repliedComments = RepliedCommentsReducer.State(comment: comment, post: post, currentUserId: currentUserId)
			}
		}

		public var id: String {
			comment.id
		}
	}

	public indirect enum Action: BindableAction {
		case binding(BindingAction<State>)
		case userComment(UserCommentReducer.Action)
		case repliedComments(RepliedCommentsReducer.Action)
		case task
		case delegate(Delegate)
		
		public enum Delegate {
			case onTapCommentReplyButton(Comment)
		}
		
	}
	
	@Dependency(\.instagramClient.databaseClient) var databaseClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.userComment, action: \.userComment) {
			UserCommentReducer()
		}
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { send in
					
				}
			case .delegate:
				return .none
			case .userComment:
				return .none
//			case let .repliedComments(.delegate(.onTapCommentReply(comment))):
//				return .send(.delegate(.onTapCommentReplyButton(comment)))
			case .repliedComments:
				return .none
			}
		}
		.ifLet(\.repliedComments, action: \.repliedComments) {
			RepliedCommentsReducer()
		}
	}
	
	
}

public struct CommentView: View {
	@Bindable var store: StoreOf<CommentReducer>
	public init(store: StoreOf<CommentReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack {
			UserCommentView(
				store: store.scope(
					state: \.userComment,
					action: \.userComment
				)
			)
			IfLetStore(store.scope(state: \.repliedComments, action: \.repliedComments)) { store in
				RepliedCommentsView(store: store)
			}
		}
		.padding(.leading, store.comment.isReplied ? AppSpacing.xxlg : AppSpacing.sm)
		.task {
			await store.send(.task).finish()
		}
	}
}
