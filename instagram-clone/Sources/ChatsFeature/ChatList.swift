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
	}
}

public struct MessageListView: View {
	@Bindable var store: StoreOf<MessageListReducer>
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<MessageListReducer>) {
		self.store = store
	}

	public var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				LazyVStack {
					ForEach(store.messages) { message in
						messageContent(message: message)
//								.overlay {
//									GradientBubbleOverlay(
//										containerSize: geometryReader.size,
//										colors: Assets.Colors.primaryMessageBubbleGradient
//									)
//									.allowsHitTesting(false)
//								}
					}
				}
			}
			.coordinateSpace(name: "ScrollViewSpace")
			.padding(.horizontal, AppSpacing.sm)
			.scrollIndicators(.hidden)
			.flippedUpsideDown()
			.onChange(of: store.scrollPosition) { _, scrollToPosition in
				if let scrollToPosition {
					withAnimation(.snappy) {
						proxy.scrollTo(scrollToPosition, anchor: .center)
					}
				}
			}
		}
		.task {
			await store.send(.task).finish()
		}
	}

	private func adjacentMessages(for message: Message) -> (Message?, Message?) {
		guard let messageIndex = store.messages.firstIndex(where: { $0.id == message.id }) else {
			return (nil, nil)
		}
		let previous = (messageIndex > 0) ? store.messages[messageIndex - 1] : nil
		let next = (messageIndex < store.messages.count - 1) ? store.messages[messageIndex + 1] : nil
		return (previous, next)
	}

	private func computeBubbleCorners(
		message: Message,
		previous: Message?,
		next: Message?
	) -> (topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
		let isNextUserSame = next != nil && (message.sender!.id) == (next!.sender!.id)
		let isPreviousUserSame = previous != nil && (message.sender!.id) == (previous!.sender!.id)
		let isMine = message.sender?.id == store.authUser.id
		var hasTimeDifferenceWithNext = false
		if let next {
			hasTimeDifferenceWithNext = next.createdAt.checkTimeDifference(message.createdAt)
		}
		var hasTimeDifferenceWithPrevious = false
		if let previous {
			hasTimeDifferenceWithPrevious = previous.createdAt.checkTimeDifference(message.createdAt)
		}
		let corner: CGFloat = 22
		let smallCorner: CGFloat = 4

		let topLeft: CGFloat = isMine
			? corner
			: (isNextUserSame && !hasTimeDifferenceWithNext ? smallCorner : corner)
		let topRight: CGFloat = isMine
			? (isNextUserSame && !hasTimeDifferenceWithNext ? smallCorner : corner)
			: corner
		let bottomLeft: CGFloat = isMine
			? corner
			: (isPreviousUserSame && !hasTimeDifferenceWithPrevious ? smallCorner : 0)
		let bottomRight: CGFloat = isMine
			? (isPreviousUserSame && !hasTimeDifferenceWithPrevious ? smallCorner : 0)
			: corner
		return (topLeft, topRight, bottomLeft, bottomRight)
	}

	private func messageContent(message: Message) -> some View {
		let (prev, next) = adjacentMessages(for: message)
		let corners = computeBubbleCorners(message: message, previous: prev, next: next)
		return MessageBubble(
			isMine: message.sender?.id == store.authUser.id,
			message: message,
			corner: RectangleCornerRadii(
				topLeading: corners.topLeft,
				bottomLeading: corners.bottomLeft,
				bottomTrailing: corners.bottomRight,
				topTrailing: corners.topRight
			)
		)
		.id(message.id)
		.flippedUpsideDown()
		.padding(.horizontal, 6)
		.padding(.vertical, -3)
	}
}
