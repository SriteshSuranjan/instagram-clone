import Foundation
import AppUI
import SwiftUI
import Shared
import ComposableArchitecture

@Reducer
public struct MessagePreviewReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var previews: [MessagePreviewContentReducer.State] = []
		public init() {}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case updatePreview(previewContent: MessagePreviewContent)
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case let .updatePreview(previewContent):
				switch previewContent {
				case .attachment:
					state.previews.append(MessagePreviewContentReducer.State(previewContent: previewContent))
				case let .editingMessage(message), let .replyMessage(message):
					let messageId = message.id
					let previewMessageIndex = state.previews.firstIndex(where: { $0.previewContent.messageId == messageId })
					if let previewMessageIndex {
						state.previews[previewMessageIndex] = MessagePreviewContentReducer.State(previewContent: previewContent)
					} else {
						state.previews.append(MessagePreviewContentReducer.State(previewContent: previewContent))
					}
				}
				
				return .none
			}
		}
	}
}

public struct MessagePreview: View {
	let store: StoreOf<MessagePreviewReducer>
	public init(store: StoreOf<MessagePreviewReducer>) {
		self.store = store
	}
	public var body: some View {
		VStack(alignment: .leading) {
			ForEach(store.previews) { preview in
				MessagePreviewContentView(
					store: Store(
						initialState: MessagePreviewContentReducer.State(previewContent: preview.previewContent),
						reducer: { MessagePreviewContentReducer() }
					)
				)
			}
		}
	}
}

public enum MessagePreviewContent: Equatable {
	case attachment(url: String)
	case replyMessage(message: Message)
	case editingMessage(message: Message)
	
	var previewIcon: String {
		switch self {
		case .attachment: return "paperclip"
		case .replyMessage: return "arrowshape.turn.up.forward.fill"
		case .editingMessage: return "pencil"
		}
	}
	var previewTitle: String {
		switch self {
		case .attachment(let urlString):
			if let url = URL(string: urlString) {
				return url.host() ?? "URL"
			}
			return "URL"
		case .replyMessage(let message):
			return "Reply to \(message.sender?.username ?? "")"
		case .editingMessage:
			return "Editing"
		}
	}
	var previewSubtitle: String {
		switch self {
		case .attachment(let url): return "url"
		case .replyMessage(let message): return message.message
		case .editingMessage(let message): return message.message
		}
	}
	var isAttachment: Bool {
		if case .attachment = self {
			return true
		}
		return false
	}
	var messageId: String? {
		switch self {
		case .attachment: return nil
		case .replyMessage(let message): return message.id
		case .editingMessage(let message): return message.id
		}
	}
}

@Reducer
public struct MessagePreviewContentReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable, Identifiable {
		var previewContent: MessagePreviewContent
		public init(previewContent: MessagePreviewContent) {
			self.previewContent = previewContent
		}
		public var id: String {
			switch previewContent {
			case .attachment(let url): return url
			case .replyMessage(let message): return message.id
			case .editingMessage(let message): return message.id
			}
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

public struct MessagePreviewContentView: View {
	let store: StoreOf<MessagePreviewContentReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<MessagePreviewContentReducer>) {
		self.store = store
	}
	public var body: some View {
		HStack(spacing: AppSpacing.lg) {
			Image(systemName: store.previewContent.previewIcon)
				.resizable()
				.scaledToFit()
				.foregroundStyle(Assets.Colors.blue)
			VStack(alignment: .leading, spacing: AppSpacing.sm) {
				Text(store.previewContent.previewTitle)
					.font(textTheme.titleLarge.font)
					.bold()
					.foregroundStyle(Assets.Colors.blue)
				Text(store.previewContent.previewSubtitle)
					.font(textTheme.bodyLarge.font)
					.foregroundStyle(Assets.Colors.bodyColor)
			}
			Spacer()
		}
		.padding(.vertical, AppSpacing.xlg)
		.padding(.horizontal, AppSpacing.md)
	}
}
