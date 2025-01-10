import AppUI
import ComposableArchitecture
import Foundation
import InstagramClient
import Shared
import SwiftUI

@Reducer
public struct MessageListReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var authUser: User
		var chat: ChatInbox
		var messages: IdentifiedArrayOf<Message> = []
		var scrollPosition: String?
		public init(authUser: User, chat: ChatInbox) {
			self.authUser = authUser
			self.chat = chat
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case messagesUpdate([Message])
		case scrollTo(messageId: String)
	}

	@Dependency(\.instagramClient.chatsClient) var chatsClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [chatId = state.chat.id] send in
					for await messages in await chatsClient.messagesOf(chatId) {
						await send(.messagesUpdate(messages))
					}
				}
			case let .messagesUpdate(messages):
				for message in messages {
					if let originalMessage = state.messages[id: message.id], originalMessage != message {
						state.messages[id: message.id] = message
					} else {
						state.messages.insert(message, at: 0)
					}
				}
				let updatedMessageIds = messages.map(\.id)
				state.messages.removeAll(where: { !updatedMessageIds.contains($0.id) })
				return .none
			case let .scrollTo(messageId):
				state.scrollPosition = messageId
				return .none
			}
		}
		._printChanges()
	}
}

public struct MessageListView: View {
	@Bindable var store: StoreOf<MessageListReducer>
	public init(store: StoreOf<MessageListReducer>) {
		self.store = store
	}

	public var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				LazyVStack {
					ForEach(store.messages) { message in
						MessageBubble(isMine: message.sender?.id == store.authUser.id, message: message)
							.id(message.id)
							.flippedUpsideDown()
							.padding(.horizontal, 6)
							.padding(.vertical, -3)
					}
				}
			}
			.scrollIndicators(.hidden)
			.flippedUpsideDown()
			.onChange(of: store.scrollPosition) { _, scrollToPosition in
				if let scrollToPosition {
					withAnimation(.snappy) {
						proxy.scrollTo(scrollToPosition, anchor: .center)
					}
				}
			}
			.task {
				await store.send(.task).finish()
			}
		}
	}
}
