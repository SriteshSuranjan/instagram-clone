import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI

@Reducer
public struct ReelsReducer {
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

public struct ReelsView: View {
	@Bindable var store: StoreOf<ReelsReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<ReelsReducer>) {
		self.store = store
	}
	public var body: some View {
		Text("Reels")
			.font(textTheme.headlineSmall.font)
	}
}


