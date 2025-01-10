import Foundation
import SwiftUI
import AppUI
import ComposableArchitecture

@Reducer
public struct ChatMessageInputTextFieldReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var message: String = ""
		public init() {}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case updateMessageInput(String)
		case onTapSendButton
		case clearInputTextField
		case delegate(Delegate)
		
		public enum Delegate {
			case onTapSendButton(String)
		}
	}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case let .updateMessageInput(message):
				state.message = message
				return .none
			case .onTapSendButton:
				guard !state.message.isEmpty else {
					return .none
				}
				return .run { [message = state.message] send in
					await send(.delegate(.onTapSendButton(message)))
					await send(.clearInputTextField)
				}
			case .clearInputTextField:
				state.message = ""
				return .none
			case .delegate:
				return .none
			}
		}
	}
}

public struct ChatMessageInputTextFieldView: View {
	@Bindable var store: StoreOf<ChatMessageInputTextFieldReducer>
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<ChatMessageInputTextFieldReducer>) {
		self.store = store
	}
	public var body: some View {
		HStack {
			Button {
				
			} label: {
				Image(systemName: "face.dashed")
					.resizable()
					.scaledToFit()
					.foregroundStyle(Assets.Colors.displayColor)
			}
			.scaleEffect()
			.frame(width: 24, height: 24)
			TextField("Message...", text: $store.message.sending(\.updateMessageInput), axis: .vertical)
				.textFieldStyle(.plain)
				.font(textTheme.bodyLarge.font)
				.fontWeight(.semibold)
				.tint(Assets.Colors.bodyColor)
			Group {
				if store.message.isEmpty {
					EmptyView()
				} else {
					Button {
						store.send(.onTapSendButton)
					} label: {
						Image(systemName: "paperplane.fill")
							.resizable()
							.scaledToFit()
							.rotationEffect(.degrees(45))
							.foregroundStyle(Assets.Colors.displayColor)
					}
					.scaleEffect()
					.frame(width: 24, height: 24)
				}
			}
			.foregroundStyle(Assets.Colors.displayColor)
		}
		.padding(.horizontal, AppSpacing.md)
		.padding(.vertical, AppSpacing.md)
		.background(
			Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.brightGray, dark: Assets.Colors.dark)
		)
		.clipShape(.rect(cornerRadius: 28))
		.padding()
	}
}
