import Foundation
import Shared
import AppUI
import SwiftUI
import ComposableArchitecture
import InstaBlocks
import InstagramBlocksUI


@Reducer
public struct RepliedCommentReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var comment: Comment
		var post: InstaBlockWrapper
		public init(comment: Comment, post: InstaBlockWrapper) {
			self.comment = comment
			self.post = post
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			}
		}
	}
}

public struct RepliedCommentView: View {
	let store: StoreOf<RepliedCommentReducer>
	public init(store: StoreOf<RepliedCommentReducer>) {
		self.store = store
	}
	public var body: some View {
		/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
	}
}
