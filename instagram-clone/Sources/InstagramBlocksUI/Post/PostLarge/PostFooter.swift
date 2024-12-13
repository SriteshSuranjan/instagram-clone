import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import InstaBlocks
import Shared

@Reducer
public struct PostFooterReducer {
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

public struct PostFooterView: View {
	@Bindable var store: StoreOf<PostFooterReducer>
	public init(store: StoreOf<PostFooterReducer>) {
		self.store = store
	}
	public var body: some View {
		/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
	}
}
