import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct ForgotPasswordReducer {
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
		EmptyReducer()
	}
}

public struct ForgotPasswordView: View {
	let store: StoreOf<ForgotPasswordReducer>
	public init(store: StoreOf<ForgotPasswordReducer>) {
		self.store = store
	}
	public var body: some View {
		/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
	}
}
