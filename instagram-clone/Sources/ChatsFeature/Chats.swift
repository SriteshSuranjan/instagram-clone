import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI


@Reducer
public struct ChatsReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public init() {}
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

public struct ChatsView: View {
	@Bindable var store: StoreOf<ChatsReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<ChatsReducer>) {
		self.store = store
	}
	public var body: some View {
		VStack {
			Text("Chats")
				.font(textTheme.titleLarge.font)
				.bold()
		}
	}
}
