import AppUI
import ComposableArchitecture
import Foundation
import InstagramClient
import Shared
import SwiftUI

@Reducer
public struct ChatsReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var authUser: User
		var chats: [ChatInbox] = []
		public init(authUser: User) {
			self.authUser = authUser
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case chatsUpdated([ChatInbox])
		case task
		case onTapBackButton
		case onTapAddChatButton
	}
	
	@Dependency(\.instagramClient.chatsClient.chats) var chats

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [userId = state.authUser.id] send in
					for await chats in await chats(userId) {
						await send(.chatsUpdated(chats), animation: .snappy)
					}
				}
			case .onTapBackButton:
				return .none
			case .onTapAddChatButton:
				return .none
			case let .chatsUpdated(chats):
				state.chats = chats
				return .none
			}
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
							Button {
								
							} label: {
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
								ChatInboxTile(chat: chat)
							}
						}
					}
					.scrollIndicators(.hidden)
				}
			
			
		}
		.padding()
		.navigationBarHidden(true)
		.task {
			await store.send(.task).finish()
		}
	}
	
}
