import Foundation
import SwiftUI
import AppUI
import Shared
import InstagramClient
import ComposableArchitecture

@Reducer
public struct ChatReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var authUser: User
		var chat: ChatInbox
		var chatAppBar: ChatAppBarReducer.State
		var chatInput = ChatMessageInputReducer.State()
		var messageList: MessageListReducer.State
		public init(authUser: User, chat: ChatInbox) {
			self.authUser = authUser
			self.chat = chat
			self.messageList = MessageListReducer.State(authUser: authUser, chat: chat)
			self.chatAppBar = ChatAppBarReducer.State(participant: chat.participant)
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case chatAppBar(ChatAppBarReducer.Action)
		case chatInput(ChatMessageInputReducer.Action)
		case messageList(MessageListReducer.Action)
	}
	
	@Dependency(\.instagramClient.chatsClient) var chatsClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.chatAppBar, action: \.chatAppBar) {
			ChatAppBarReducer()
		}
		Scope(state: \.chatInput, action: \.chatInput) {
			ChatMessageInputReducer()
		}
		Scope(state: \.messageList, action: \.messageList) {
			MessageListReducer()
		}
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .chatAppBar:
				return .none
			case let .chatInput(.messageInputTextField(.delegate(.onTapSendButton(message)))):
				return .run { [chatId = state.chat.id, sender = state.authUser, receiver = state.chat.participant] send in
					try await chatsClient.sendMessage(chatId, sender, receiver, Message(message: message))
				}
			case .chatInput:
				return .none
			case .messageList:
				return .none
			}
		}
	}
}

public struct ChatView: View {
	let store: StoreOf<ChatReducer>
	public init(store: StoreOf<ChatReducer>) {
		self.store = store
	}
	public var body: some View {
		VStack(alignment: .leading) {
			ChatAppBarView(store: store.scope(state: \.chatAppBar, action: \.chatAppBar))
				.padding()
			MessageListView(store: store.scope(state: \.messageList, action: \.messageList))
		}
		.safeAreaInset(edge: .bottom) {
			ChatMessageInputView(store: store.scope(state: \.chatInput, action: \.chatInput))
		}
		.navigationBarHidden(true)
	}
}
