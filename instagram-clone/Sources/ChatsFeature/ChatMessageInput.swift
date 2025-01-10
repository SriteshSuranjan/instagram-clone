import Foundation
import SwiftUI
import AppUI
import ComposableArchitecture

@Reducer
public struct ChatMessageInputReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var messageInputTextField = ChatMessageInputTextFieldReducer.State()
		var messagePreview: MessagePreviewReducer.State?
		public init() {}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case messageInputTextField(ChatMessageInputTextFieldReducer.Action)
		case messagePreview(MessagePreviewReducer.Action)
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.messageInputTextField, action: \.messageInputTextField) {
			ChatMessageInputTextFieldReducer()
		}
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .messageInputTextField:
				return .none
			case .messagePreview:
				return .none
			}
		}
		.ifLet(\.messagePreview, action: \.messagePreview) {
			MessagePreviewReducer()
		}
	}
}

public struct ChatMessageInputView: View {
	let store: StoreOf<ChatMessageInputReducer>
	public init(store: StoreOf<ChatMessageInputReducer>) {
		self.store = store
	}
	public var body: some View {
		VStack {
			if let messagePreviewStore = store.scope(state: \.messagePreview, action: \.messagePreview) {
				MessagePreview(store: messagePreviewStore)
			}
			ChatMessageInputTextFieldView(
				store: store.scope(state: \.messageInputTextField, action: \.messageInputTextField)
			)
		}
		.frame(maxWidth: .infinity)
	}
}
