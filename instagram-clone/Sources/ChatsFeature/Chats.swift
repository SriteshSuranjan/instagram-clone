import AppUI
import ComposableArchitecture
import Foundation
import InstagramClient
import Shared
import SwiftUI

@Reducer
public struct ChatsReducer {
	public init() {}
	
	@Reducer(state: .equatable)
	public enum Destination {
		case chat(ChatReducer)
	}
	
	@ObservableState
	public struct State: Equatable {
		var authUser: User
		var chats: [ChatInbox] = []
		@Presents var alert: AlertState<Action.Alert>?
		@Presents var destination: Destination.State?
		public init(authUser: User) {
			self.authUser = authUser
		}
	}

	public enum Action: BindableAction {
		case alert(PresentationAction<Alert>)
		case binding(BindingAction<State>)
		case chatsUpdated([ChatInbox])
		case destination(PresentationAction<Destination.Action>)
		case task
		case onTapBackButton
		case onTapAddChatButton
		case onTapChat(chat: ChatInbox)
		case onTapDeleteChatButton(chatId: String)
		case delegate(Delegate)
		public enum Delegate {
			case onTapBackButton
		}
		public enum Alert: Equatable {
			case confirmDeleteChat(chatId: String)
		}
	}

	@Dependency(\.instagramClient.chatsClient) var chatsClient

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case let .alert(.presented(.confirmDeleteChat(chatId))):
				state.alert = nil
				return .run { [userId = state.authUser.id] _ in
					try await chatsClient.deleteChat(chatId, userId)
				}
			case .alert:
				return .none
			case .binding:
				return .none
			case .destination:
				return .none
			case .task:
				return .run { [userId = state.authUser.id] send in
					for await chats in await chatsClient.chats(userId) {
						await send(.chatsUpdated(chats), animation: .snappy)
					}
				}
			case let .onTapChat(chat):
				state.destination = .chat(ChatReducer.State(authUser: state.authUser, chat: chat))
				return .none
			case .onTapBackButton:
				return .send(.delegate(.onTapBackButton))
			case .onTapAddChatButton:
				return .none
			case let .onTapDeleteChatButton(chatId):
				state.alert = AlertState(
					title: {
						TextState("Are you sure you want to delete this chat?")
					},
					actions: {
						ButtonState(role: .cancel) {
							TextState("Cancel")
						}
						ButtonState(role: .destructive, action: .send(.confirmDeleteChat(chatId: chatId))) {
							TextState("Delete")
						}
					}
				)
				return .none
			case let .chatsUpdated(chats):
				state.chats = chats
				return .none
			case .delegate:
				return .none
			}
		}
		.ifLet(\.$alert, action: \.alert)
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
		}
	}
}

public struct ChatsView: View {
	@Bindable var store: StoreOf<ChatsReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<ChatsReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack {
			AppNavigationBar(
				title: store.authUser.displayUsername,
				backButtonAction: {
					store.send(.onTapBackButton)
				},
				actions: [AppNavigationBarTrailingAction(
					icon: .system("plus"),
					action: {
						store.send(.onTapAddChatButton)
					}
				)]
			)

			if store.chats.isEmpty {
				ContentUnavailableView {
					VStack {
						Spacer()
						Group {
							Assets.Icons.chatCircle
								.view(width: 80, height: 80)
							Text("No chats yet!")
						}
						.font(textTheme.headlineLarge.font)
						.fontWeight(.semibold)
						.foregroundStyle(Assets.Colors.bodyColor)
						.padding(.bottom)
						Button {} label: {
							Text("Start a chat")
								.font(textTheme.bodyLarge.font)
								.foregroundStyle(Assets.Colors.bodyColor)
								.padding(.horizontal, AppSpacing.lg)
								.padding(.vertical, AppSpacing.sm)
								.background(
									Assets.Colors.bottomSheetModalBackgroundColor
								)
								.clipShape(.capsule)
								.contentShape(.rect)
						}
						.scaleEffect()
						Spacer()
					}
				}
			} else {
				ScrollView {
					LazyVStack {
						ForEach(store.chats) { chat in
							Button {
								store.send(.onTapChat(chat: chat))
							} label: {
								ChatInboxTile(chat: chat)
									.contentShape(.rect)
							}
							.contextMenu {
								Button(role: .destructive) {
									store.send(.onTapDeleteChatButton(chatId: chat.id))
								} label: {
									Label("Delete", systemImage: "trash")
								}
							}
						}
					}
				}
				.scrollIndicators(.hidden)
			}
		}
		.alert($store.scope(state: \.alert, action: \.alert))
		.navigationDestination(item: $store.scope(state: \.destination?.chat, action: \.destination.chat)) { chatStore in
			ChatView(store: chatStore)
		}
		.padding()
		.toolbar(.hidden, for: .navigationBar)
		.task {
			await store.send(.task).finish()
		}
	}
}
