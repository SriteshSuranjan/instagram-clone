import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI

@Reducer
public struct FeedReducer {
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

public struct FeedView: View {
	@Environment(\.textTheme) var textTheme
	@Bindable var store: StoreOf<FeedReducer>
	public init(store: StoreOf<FeedReducer>) {
		self.store = store
	}
	public var body: some View {
		Text("Feed")
			.font(textTheme.headlineSmall.font)
	}
}
